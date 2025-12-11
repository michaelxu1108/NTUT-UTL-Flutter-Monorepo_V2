import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../domain/entity/mlx_sensor_data.dart';
import 'bracelet_packet_parser.dart';

/// 手環藍牙連接模組（使用 Nordic UART Service）
///
/// Nordic UART Service (NUS) UUID:
/// - Service: 6E400001-B5A3-F393-E0A9-E50E24DCCA9E
/// - TX Characteristic: 6E400003-B5A3-F393-E0A9-E50E24DCCA9E (手環 → App)
/// - RX Characteristic: 6E400002-B5A3-F393-E0A9-E50E24DCCA9E (App → 手環)
class BraceletBluetoothModule {
  // NUS UUID 定義
  static final Guid nusServiceUuid = Guid("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
  static final Guid nusTxUuid = Guid("6E400003-B5A3-F393-E0A9-E50E24DCCA9E");
  static final Guid nusRxUuid = Guid("6E400002-B5A3-F393-E0A9-E50E24DCCA9E");

  // 手環指令定義
  static const int cmdOutputAcc = 0x61;  // 'a' - 開始資料串流
  static const int cmdCalibrate = 0x63;   // 'c' - IMU 校正
  static const int cmdInit = 0x64;        // 'd' - IMU 初始化
  static const int cmdReset = 0x72;       // 'r' - 重開機

  BluetoothDevice? _device;
  BluetoothCharacteristic? _txCharacteristic;
  BluetoothCharacteristic? _rxCharacteristic;

  final StreamController<MlxSensorData> _dataStreamController = StreamController<MlxSensorData>.broadcast();
  StreamSubscription? _characteristicSubscription;

  /// 資料串流（解析後的感測器資料）
  Stream<MlxSensorData> get dataStream => _dataStreamController.stream;

  /// 連接狀態
  bool get isConnected => _device != null && _txCharacteristic != null && _rxCharacteristic != null;

  /// 連接到手環
  Future<bool> connect(BluetoothDevice device) async {
    try {
      _device = device;

      // 連接裝置
      await device.connect(
        license: License.free,
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );
      print('已連接到裝置: ${device.platformName}');

      // 延遲一下等待服務就緒
      await Future.delayed(const Duration(milliseconds: 500));

      // 發現服務
      final services = await device.discoverServices();
      print('發現 ${services.length} 個服務');

      // 尋找 NUS 服務
      BluetoothService? nusService;
      for (var service in services) {
        print('服務 UUID: ${service.uuid}');
        if (service.uuid == nusServiceUuid) {
          nusService = service;
          break;
        }
      }

      if (nusService == null) {
        print('找不到 NUS 服務');
        await device.disconnect();
        return false;
      }

      print('找到 NUS 服務');

      // 尋找 TX 和 RX Characteristics
      for (var characteristic in nusService.characteristics) {
        print('Characteristic UUID: ${characteristic.uuid}');
        if (characteristic.uuid == nusTxUuid) {
          _txCharacteristic = characteristic;
          print('找到 TX Characteristic');
        } else if (characteristic.uuid == nusRxUuid) {
          _rxCharacteristic = characteristic;
          print('找到 RX Characteristic');
        }
      }

      if (_txCharacteristic == null || _rxCharacteristic == null) {
        print('找不到必要的 Characteristics');
        await device.disconnect();
        return false;
      }

      // 訂閱 TX Characteristic（接收手環資料）
      await _txCharacteristic!.setNotifyValue(true);
      _characteristicSubscription = _txCharacteristic!.lastValueStream.listen((data) {
        _onDataReceived(data, device.remoteId.toString());
      });

      print('已訂閱 TX Characteristic');

      // 發送開始串流指令
      await startStreaming();

      return true;
    } catch (e) {
      print('連接失敗: $e');
      _device = null;
      _txCharacteristic = null;
      _rxCharacteristic = null;
      return false;
    }
  }

  /// 斷開連接
  Future<void> disconnect() async {
    await _characteristicSubscription?.cancel();
    _characteristicSubscription = null;

    if (_device != null) {
      try {
        await _device!.disconnect();
      } catch (e) {
        print('斷開連接時發生錯誤: $e');
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
    _characteristicSubscription?.cancel();
    _dataStreamController.close();
  }
}
