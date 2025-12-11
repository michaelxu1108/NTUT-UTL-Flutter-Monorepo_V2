import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../domain/entity/mlx_sensor_data.dart';
import '../../infrastructure/source/bluetooth/bracelet_bluetooth_module.dart';
import '../../infrastructure/service/csv_export_service.dart';

/// 手環 App 狀態管理
class BraceletChangeNotifier extends ChangeNotifier {
  final dynamic
  _bluetoothModule; // 可以是 BraceletBluetoothModule 或 MockBraceletBluetoothModule

  /// 建構子 - 支援注入藍牙模組（真實或 Mock）
  BraceletChangeNotifier({dynamic bluetoothModule})
    : _bluetoothModule = bluetoothModule ?? BraceletBluetoothModule();

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

  /// 新增資料
  void _addData(MlxSensorData data) {
    _dataList.add(data);

    // 限制資料筆數，避免記憶體溢位
    if (_dataList.length > maxDataCount) {
      _dataList.removeAt(0);
    }

    notifyListeners();
  }

  /// 清除所有資料（重置）
  void clearData() {
    _dataList.clear();
    notifyListeners();
  }

  /// 重置（清除資料並停止記錄）
  void reset() {
    stopRecording();
    clearData();
  }

  // ==================== CSV 匯出 ====================

  /// 匯出 CSV
  Future<String?> exportCsv() async {
    if (_dataList.isEmpty) {
      return null;
    }

    _isExporting = true;
    notifyListeners();

    try {
      final filePath = await CsvExportService.exportToCsv(_dataList);
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
    super.dispose();
  }
}
