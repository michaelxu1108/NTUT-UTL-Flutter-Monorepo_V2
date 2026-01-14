import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../domain/entity/mlx_sensor_data.dart';
import '../../infrastructure/source/bluetooth/bracelet_bluetooth_module.dart';
import '../../infrastructure/service/csv_export_service.dart';
import '../../infrastructure/repository/sensor_data_repository.dart';

/// 手環 App 狀態管理
class BraceletChangeNotifier extends ChangeNotifier {
  final dynamic
  _bluetoothModule; // 可以是 BraceletBluetoothModule 或 MockBraceletBluetoothModule

  final SensorDataRepository _repository;

  /// 建構子 - 支援注入藍牙模組和資料庫
  BraceletChangeNotifier({
    dynamic bluetoothModule,
    SensorDataRepository? repository,
  })  : _bluetoothModule = bluetoothModule ?? BraceletBluetoothModule(),
        _repository = repository ?? SensorDataRepository();

  // ==================== 狀態變數 ====================

  /// 連接的裝置
  BluetoothDevice? _connectedDevice;

  /// 感測器資料列表（用於顯示圖表和匯出 CSV）
  final List<MlxSensorData> _dataList = [];

  /// 是否正在記錄
  bool _isRecording = false;

  /// 是否正在匯出 CSV
  bool _isExporting = false;

  /// 資料串流訂閱
  StreamSubscription<MlxSensorData>? _dataSubscription;

  /// 最大資料筆數（避免記憶體溢位）
  static const int maxDataCount = 3000; // 50 Hz × 60 秒 = 3000 筆

  // ==================== Getters ====================

  BluetoothDevice? get connectedDevice => _connectedDevice;
  List<MlxSensorData> get dataList => _dataList;
  bool get isRecording => _isRecording;
  bool get isExporting => _isExporting;
  bool get isConnected => _bluetoothModule.isConnected;

  /// 連接狀態串流（供 UI 顯示連接過程）
  Stream<ConnectionStatus> get connectionStatusStream =>
      _bluetoothModule.connectionStatusStream;

  /// 最新的資料
  MlxSensorData? get latestData => _dataList.isEmpty ? null : _dataList.last;

  /// 資料筆數
  int get dataCount => _dataList.length;

  // ==================== 藍牙連接 ====================

  /// 連接到手環
  Future<bool> connectToDevice(BluetoothDevice device) async {
    final success = await _bluetoothModule.connect(device);

    if (success) {
      _connectedDevice = device;

      // 訂閱資料串流
      _dataSubscription = _bluetoothModule.dataStream.listen((data) {
        if (_isRecording) {
          _addData(data);
        }
      });

      notifyListeners();
    }

    return success;
  }

  /// 斷開連接
  Future<void> disconnect() async {
    await _dataSubscription?.cancel();
    _dataSubscription = null;

    await _bluetoothModule.disconnect();
    _connectedDevice = null;

    notifyListeners();
  }

  // ==================== 資料記錄 ====================

  /// 開始記錄
  void startRecording() {
    _isRecording = true;
    notifyListeners();
  }

  /// 停止記錄
  void stopRecording() {
    _isRecording = false;
    notifyListeners();
  }

  /// 切換記錄狀態
  void toggleRecording() {
    _isRecording = !_isRecording;
    notifyListeners();
  }

  /// 新增資料（同時寫入記憶體和資料庫）
  void _addData(MlxSensorData data) {
    // 1. 寫入記憶體 List（用於即時圖表顯示）
    _dataList.add(data);

    // 限制記憶體中的資料筆數（保留最近 3000 筆用於圖表顯示）
    if (_dataList.length > maxDataCount) {
      _dataList.removeAt(0);
    }

    // 2. 寫入 Hive 資料庫（儲存完整資料，無上限）
    _repository.add(data).catchError((e) {
      print('資料庫寫入失敗: $e');
    });

    notifyListeners();
  }

  /// 清除所有資料（同時清除記憶體和資料庫）
  Future<void> clearData() async {
    // 1. 清除記憶體
    _dataList.clear();

    // 2. 清除資料庫
    await _repository.clear().catchError((e) {
      print('資料庫清除失敗: $e');
    });

    notifyListeners();
  }

  /// 重置（清除資料並停止記錄）
  Future<void> reset() async {
    stopRecording();
    await clearData();
  }

  /// 取得資料庫中的總筆數
  int get totalDataCount => _repository.count;

  /// 取得資料庫檔案大小（MB）
  double get databaseSizeMB => _repository.sizeInMB;

  /// 取得資料庫檔案路徑
  String? get databasePath => _repository.databasePath;

  // ==================== CSV 匯出 ====================

  /// 匯出 CSV（從資料庫讀取完整資料）
  Future<String?> exportCsv() async {
    // 從資料庫讀取所有資料（而不是只用記憶體中的 3000 筆）
    final allData = _repository.getAll();

    if (allData.isEmpty) {
      return null;
    }

    _isExporting = true;
    notifyListeners();

    try {
      final filePath = await CsvExportService.exportToCsv(allData);
      print('CSV 匯出成功：${allData.length} 筆資料 (${databaseSizeMB.toStringAsFixed(2)} MB)');
      return filePath;
    } catch (e) {
      print('CSV 匯出失敗: $e');
      return null;
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  // ==================== 手環指令 ====================

  /// 發送校正指令
  Future<bool> calibrate() async {
    return await _bluetoothModule.calibrate();
  }

  /// 發送初始化指令
  Future<bool> initialize() async {
    return await _bluetoothModule.initialize();
  }

  /// 發送重啟指令
  Future<bool> resetDevice() async {
    return await _bluetoothModule.reset();
  }

  // ==================== 生命週期 ====================

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _bluetoothModule.dispose();
    // 注意：Hive box 通常不需要在 dispose 中關閉，因為可能被其他地方使用
    // 如果需要關閉，應該在 App 層級的 main.dart 中處理
    super.dispose();
  }
}
