import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../domain/entity/amulet_entity.dart';
import 'bluetooth_received_packet.dart';

/// Mock 藍牙模組 - 用於測試，自動生成假的感測器數據
///
/// 功能：
/// - 每 20ms (50 Hz) 生成一次假數據
/// - 模擬真實的感測器數值變化（加速度、磁力計、姿態等）
/// - 使用正弦波模擬自然的運動模式
class MockBluetoothModule {
  Timer? _timer;
  final StreamController<BluetoothReceivedPacket> _controller = StreamController.broadcast();
  final Random _random = Random();

  // 模擬的運動參數
  double _time = 0.0;
  int _postureIndex = 0;

  // 模擬設備資訊
  static const String mockDeviceId = 'MOCK:00:00:00:00:00';
  static const String mockDeviceName = 'Htag (Mock)';

  MockBluetoothModule() {
    debugPrint('🔧 MockBluetoothModule 初始化 - 將自動生成假資料');
  }

  /// 開始生成假數據
  void startGeneratingData() {
    debugPrint('🟢 開始生成假數據 (50 Hz)');
    _timer = Timer.periodic(const Duration(milliseconds: 20), (_) {
      _generateMockData();
      _time += 0.02; // 增加時間 (20ms = 0.02s)
    });
  }

  /// 停止生成假數據
  void stopGeneratingData() {
    debugPrint('🔴 停止生成假數據');
    _timer?.cancel();
    _timer = null;
  }

  /// 生成模擬的感測器數據封包 (42 bytes)
  void _generateMockData() {
    final bytes = Uint8List(42);
    final byteData = ByteData.sublistView(bytes);

    // 模擬加速度數據 (使用正弦波 + 噪音)
    // 假設使用者正在輕微移動
    final accXBase = (sin(_time * 0.5) * 500).toInt();  // ±500 範圍
    final accYBase = (cos(_time * 0.7) * 300).toInt();  // ±300 範圍
    final accZBase = (sin(_time * 0.3) * 200 + 16384).toInt();  // 接近 1g 的重力

    byteData.setInt16(0, accXBase + _randomNoise(50), Endian.big);      // accX [0][1]
    byteData.setInt16(2, accYBase + _randomNoise(50), Endian.big);      // accY [2][3]
    byteData.setInt16(4, accZBase + _randomNoise(50), Endian.big);      // accZ [4][5]

    // 加速度總和
    final accTotal = sqrt(pow(accXBase, 2) + pow(accYBase, 2) + pow(accZBase, 2)).toInt();
    byteData.setUint16(6, accTotal.clamp(0, 65535), Endian.big);        // accTotal [6][7]

    // 模擬歐拉角 (roll, pitch, yaw)
    final roll = (sin(_time * 0.4) * 1000).toInt();    // ±1000
    final pitch = (cos(_time * 0.6) * 800).toInt();    // ±800
    final yaw = (sin(_time * 0.3) * 1500).toInt();     // ±1500

    byteData.setInt16(8, roll + _randomNoise(20), Endian.big);          // roll [8][9]
    byteData.setInt16(10, pitch + _randomNoise(20), Endian.big);        // pitch [10][11]
    byteData.setInt16(12, yaw + _randomNoise(30), Endian.big);          // yaw [12][13]

    // 模擬磁力計數據
    final magXBase = (sin(_time * 0.2) * 2000 + 10000).toInt();   // 8000~12000 範圍
    final magYBase = (cos(_time * 0.25) * 1500 + 8000).toInt();   // 6500~9500 範圍
    final magZBase = (sin(_time * 0.15) * 1000 + 5000).toInt();   // 4000~6000 範圍

    byteData.setInt16(14, magXBase + _randomNoise(100), Endian.big);    // magX [14][15]
    byteData.setInt16(16, magYBase + _randomNoise(100), Endian.big);    // magY [16][17]
    byteData.setInt16(18, magZBase + _randomNoise(100), Endian.big);    // magZ [18][19]

    // 磁力計總和
    final magTotal = sqrt(pow(magXBase, 2) + pow(magYBase, 2) + pow(magZBase, 2)).toInt();
    byteData.setUint16(20, magTotal.clamp(0, 65535), Endian.big);       // magTotal [20][21]

    // 溫度 (模擬 25-30°C)
    final temperature = (2500 + sin(_time * 0.1) * 250 + _randomNoise(50)).toInt();
    byteData.setUint16(24, temperature.clamp(0, 65535), Endian.big);    // temperature [24][25]

    // 姿態 (每5秒切換一次)
    if (_time % 5.0 < 0.02) {  // 每5秒切換
      _postureIndex = (_postureIndex + 1) % AmuletPostureType.values.length;
    }
    byteData.setUint8(26, _postureIndex);                                // posture [26]

    // Beacon RSSI (模擬信號強度變化 -40 ~ -80 dBm)
    final rssi = -60 + (sin(_time * 0.3) * 20).toInt() + _randomNoise(5);
    byteData.setInt16(27, rssi, Endian.big);                             // beaconRssi [27][28]

    // Direction (0-360 度，緩慢旋轉)
    final direction = ((_time * 10) % 360).toInt();
    byteData.setUint8(29, direction);                                    // direction [29]

    // ADC (模擬 ADC 數值)
    final adc = (32768 + sin(_time * 0.5) * 5000).toInt();
    byteData.setInt16(30, adc, Endian.big);                              // adc [30][31]

    // 電池 (85-100%)
    final battery = (90 + sin(_time * 0.05) * 10).toInt();
    byteData.setUint8(32, battery.clamp(0, 100));                        // battery [32]

    // Area (模擬區域 0-10)
    final area = (_time ~/ 10) % 11;
    byteData.setUint8(33, area);                                         // area [33]

    // 步數 (緩慢累加)
    final step = (_time * 2).toInt();
    byteData.setInt16(34, step, Endian.big);                             // step [34][35]

    // Point (模擬點位 0-10)
    final point = (sin(_time * 0.4) * 5 + 5).toInt();
    byteData.setUint8(36, point.clamp(0, 10));                           // point [36]

    // Pressure (氣壓/高度) - Float32, little endian
    final pressure = 1013.25 + sin(_time * 0.2) * 50.0 + _randomNoise(5);
    byteData.setFloat32(38, pressure, Endian.little);                    // pressure [38-41]

    // 創建封包並發送
    final packet = BluetoothReceivedPacket(
      deviceId: mockDeviceId,
      deviceName: mockDeviceName,
      data: bytes,
    );

    _controller.add(packet);
  }

  /// 生成隨機噪音
  int _randomNoise(int range) {
    return _random.nextInt(range * 2) - range;
  }

  /// 接收封包的 Stream
  Stream<BluetoothReceivedPacket> get onReceivePacket => _controller.stream;

  /// 模擬發送指令 (總是成功)
  Future<bool> sendCommand({required String command}) async {
    debugPrint('📤 Mock: 發送指令 0x$command');
    // 模擬延遲
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }

  /// 清理資源
  void cancel() {
    debugPrint('🧹 MockBluetoothModule 清理資源');
    stopGeneratingData();
    _controller.close();
  }
}
