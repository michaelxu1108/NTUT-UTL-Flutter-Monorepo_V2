import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../domain/entity/mlx_sensor_data.dart';
import 'bracelet_packet_parser.dart';

/// 連接狀態訊息
class ConnectionStatus {
  final String message;
  final bool isError;
  final bool isComplete;

  ConnectionStatus({
    required this.message,
    this.isError = false,
    this.isComplete = false,
  });
}

/// 手環藍牙連接模組（使用 Nordic UART Service）
///
/// Nordic UART Service (NUS) UUID:
/// - Service: 6E400001-B5A3-F393-E0A9-E50E24DCCA9E
/// - TX Characteristic: 6E400003-B5A3-F393-E0A9-E50E24DCCA9E (手環 → App)
/// - RX Characteristic: 6E400002-B5A3-F393-E0A9-E50E24DCCA9E (App → 手環)
class BraceletBluetoothModule {
  // NUS UUID 定義
  static final Guid nusServiceUuid = Guid(
    "6E400001-B5A3-F393-E0A9-E50E24DCCA9E",
  );
  static final Guid nusTxUuid = Guid("6E400003-B5A3-F393-E0A9-E50E24DCCA9E");
  static final Guid nusRxUuid = Guid("6E400002-B5A3-F393-E0A9-E50E24DCCA9E");

  // 手環指令定義
  static const int cmdOutputAcc = 0x61; // 'a' - 開始資料串流
  static const int cmdCalibrate = 0x63; // 'c' - IMU 校正
  static const int cmdInit = 0x64; // 'd' - IMU 初始化
  static const int cmdReset = 0x72; // 'r' - 重開機

  BluetoothDevice? _device;
  BluetoothCharacteristic? _txCharacteristic;
  BluetoothCharacteristic? _rxCharacteristic;

  final StreamController<MlxSensorData> _dataStreamController =
      StreamController<MlxSensorData>.broadcast();
  final StreamController<ConnectionStatus> _connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();
  StreamSubscription? _characteristicSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  /// 資料串流（解析後的感測器資料）
  Stream<MlxSensorData> get dataStream => _dataStreamController.stream;

  /// 連接狀態訊息串流（供 UI 顯示）
  Stream<ConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  /// 連接狀態（使用實際的藍牙連接狀態）
  bool get isConnected => _device?.isConnected ?? false;

  /// 發送連接狀態訊息
  void _sendStatus(String message, {bool isError = false, bool isComplete = false}) {
    final status = ConnectionStatus(
      message: message,
      isError: isError,
      isComplete: isComplete,
    );
    _connectionStatusController.add(status);
    print(isError ? '❌ $message' : (isComplete ? '🎉 $message' : '🔵 $message'));
  }

  /// 連接到手環
  Future<bool> connect(BluetoothDevice device) async {
    try {
      _device = device;

      final deviceName = device.platformName.isEmpty ? '未命名裝置' : device.platformName;
      _sendStatus('正在連接到 $deviceName...');

      // 確保裝置完全斷開（解決錯誤 133）
      try {
        await device.disconnect();
        print('🔄 已確保裝置斷開');
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        print('⚠️ 裝置斷開檢查: $e');
      }

      // 連接裝置
      await device.connect(
        license: License.free,
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );
      _sendStatus('已連接到裝置');

      // 監聽連接狀態變化
      _connectionStateSubscription = device.connectionState.listen((state) {
        print('📡 連接狀態變化: $state');
        if (state == BluetoothConnectionState.disconnected) {
          print('⚠️ 裝置已斷開連接');
          _handleDisconnection();
        }
      });

      // 延遲一下等待服務就緒
      _sendStatus('等待服務就緒...');
      await Future.delayed(const Duration(milliseconds: 500));

      // 發現服務
      _sendStatus('正在搜尋服務...');
      final services = await device.discoverServices();
      _sendStatus('發現 ${services.length} 個藍牙服務');

      // 尋找 NUS 服務
      _sendStatus('正在搜尋手環服務...');
      BluetoothService? nusService;
      for (var service in services) {
        print('  - 服務 UUID: ${service.uuid}');
        if (service.uuid == nusServiceUuid) {
          nusService = service;
          break;
        }
      }

      if (nusService == null) {
        final availableServices = services.map((s) => s.uuid.toString()).join('\n');
        _sendStatus(
          '找不到手環服務\n\n您的裝置可能不是支援的手環型號。\n\n可用服務：\n$availableServices',
          isError: true,
        );
        await device.disconnect();
        return false;
      }

      _sendStatus('找到手環服務');

      // 尋找 TX 和 RX Characteristics
      _sendStatus('正在配置通訊通道...');
      for (var characteristic in nusService.characteristics) {
        print('  - Characteristic UUID: ${characteristic.uuid}');
        if (characteristic.uuid == nusTxUuid) {
          _txCharacteristic = characteristic;
        } else if (characteristic.uuid == nusRxUuid) {
          _rxCharacteristic = characteristic;
        }
      }

      if (_txCharacteristic == null || _rxCharacteristic == null) {
        final missingParts = <String>[];
        if (_txCharacteristic == null) missingParts.add('接收通道 (TX)');
        if (_rxCharacteristic == null) missingParts.add('發送通道 (RX)');

        _sendStatus(
          '通訊通道配置失敗\n\n缺少：${missingParts.join("、")}\n\n請確認手環韌體版本是否正確',
          isError: true,
        );
        await device.disconnect();
        return false;
      }

      // 訂閱 TX Characteristic（接收手環資料）
      _sendStatus('正在啟用資料接收...');
      await _txCharacteristic!.setNotifyValue(true);
      _characteristicSubscription = _txCharacteristic!.lastValueStream.listen((
        data,
      ) {
        _onDataReceived(data, device.remoteId.toString());
      });

      // 發送開始串流指令
      _sendStatus('正在啟動資料串流...');
      await startStreaming();

      _sendStatus('連接完成！手環已就緒', isComplete: true);
      return true;
    } catch (e) {
      String errorMessage = '連接失敗';

      // 根據錯誤類型提供更詳細的說明
      if (e.toString().contains('133') || e.toString().contains('ANDROID_SPECIFIC_ERROR')) {
        // Android 錯誤 133 - GATT 連接錯誤
        errorMessage = '藍牙連接錯誤 (錯誤 133)\n\n'
            '這是 Android 系統的藍牙快取問題。\n\n'
            '請嘗試以下解決方法：\n'
            '1. 關閉並重新開啟手機藍牙\n'
            '2. 確保手環沒有連接到其他裝置\n'
            '3. 重新啟動 App 後再試\n'
            '4. 如果問題持續，請重新啟動手機\n\n'
            '建議：請先關閉藍牙，等待 5 秒後再開啟';
      } else if (e.toString().contains('timeout') || e.toString().contains('TimeoutException')) {
        errorMessage = '連接超時\n\n可能原因：\n• 手環距離太遠\n• 手環未開機\n• 手環電量不足\n\n請靠近手環後重試';
      } else if (e.toString().contains('disconnected')) {
        errorMessage = '裝置已斷線\n\n手環可能在連接過程中關機或失去連接';
      } else if (e.toString().contains('permission')) {
        errorMessage = '權限不足\n\n請在設定中授予藍牙權限';
      } else {
        errorMessage = '連接失敗\n\n錯誤詳情：\n$e';
      }

      _sendStatus(errorMessage, isError: true);

      // 清理資源
      await _connectionStateSubscription?.cancel();
      _connectionStateSubscription = null;

      // 確保裝置完全斷開
      if (_device != null) {
        try {
          await _device!.disconnect();
          print('🔄 錯誤處理：已斷開裝置');
        } catch (disconnectError) {
          print('⚠️ 錯誤處理：斷開裝置時發生錯誤: $disconnectError');
        }
      }

      _device = null;
      _txCharacteristic = null;
      _rxCharacteristic = null;
      return false;
    }
  }

  /// 處理裝置斷線
  void _handleDisconnection() {
    print('🔴 處理裝置斷線...');
    _device = null;
    _txCharacteristic = null;
    _rxCharacteristic = null;
  }

  /// 斷開連接
  Future<void> disconnect() async {
    print('🔌 斷開連接...');

    // 取消資料訂閱
    await _characteristicSubscription?.cancel();
    _characteristicSubscription = null;

    // 取消連接狀態訂閱
    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;

    // 斷開藍牙連接
    if (_device != null) {
      try {
        await _device!.disconnect();
        print('✅ 已斷開連接');
      } catch (e) {
        print('⚠️ 斷開連接時發生錯誤: $e');
      }
    }

    _device = null;
    _txCharacteristic = null;
    _rxCharacteristic = null;
  }

  /// 接收到資料時的處理
  void _onDataReceived(List<int> data, String deviceId) {
    if (data.isEmpty) return;

    print('收到資料: ${data.length} bytes');

    // 解析封包
    final sensorData = BraceletPacketParser.parse(data, deviceId);
    if (sensorData != null) {
      _dataStreamController.add(sensorData);
    }
  }

  // ==================== 指令發送 ====================

  /// 發送開始串流指令 ('a')
  Future<bool> startStreaming() async {
    return await _sendCommand(cmdOutputAcc, '開始串流');
  }

  /// 發送校正指令 ('c')
  Future<bool> calibrate() async {
    return await _sendCommand(cmdCalibrate, '校正 IMU');
  }

  /// 發送初始化指令 ('d')
  Future<bool> initialize() async {
    return await _sendCommand(cmdInit, '初始化 IMU');
  }

  /// 發送重啟指令 ('r')
  Future<bool> reset() async {
    return await _sendCommand(cmdReset, '重啟手環');
  }

  /// 發送指令到手環
  Future<bool> _sendCommand(int command, String description) async {
    if (_rxCharacteristic == null) {
      print('$description 失敗: RX Characteristic 不存在');
      return false;
    }

    try {
      await _rxCharacteristic!.write([command], withoutResponse: false);
      print('$description 指令已發送: 0x${command.toRadixString(16)}');
      return true;
    } catch (e) {
      print('$description 失敗: $e');
      return false;
    }
  }

  /// 釋放資源
  void dispose() {
    print('🗑️ 釋放 BraceletBluetoothModule 資源...');
    _characteristicSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _dataStreamController.close();
    _connectionStatusController.close();
  }
}
