import 'dart:async';
import 'dart:math';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../domain/entity/mlx_sensor_data.dart';

/// ============================================
/// Mock 藍牙模組 - 自動生成假資料
/// ============================================
///
/// 此模組用於在沒有實體藍牙裝置時測試 UI
/// 會自動生成模擬的感測器資料，包括：
/// - ICM-20948 九軸 IMU 資料（加速度、陀螺儀、磁力計）
/// - 4 顆 MLX90393 磁力計資料
///
/// 資料生成特性：
/// - 每 20ms 生成一筆資料（模擬 50 Hz 取樣率）
/// - 包含隨機變化模擬真實感測器噪音
/// - 模擬手部動作的正弦波模式
class MockBraceletBluetoothModule {
  final StreamController<MlxSensorData> _dataController =
      StreamController.broadcast();

  Timer? _timer;
  final Random _random = Random();
  int _idCounter = 0;

  /// 是否已連接（Mock 模式永遠為 true）
  bool get isConnected => _timer != null && _timer!.isActive;

  /// 資料串流
  Stream<MlxSensorData> get dataStream => _dataController.stream;

  /// 模擬連接（自動開始生成資料）
  Future<bool> connect(BluetoothDevice device) async {
    print('🔧 [Mock] 模擬連接到裝置: ${device.platformName}');

    // 模擬連接延遲
    await Future.delayed(const Duration(milliseconds: 500));

    // 開始生成假資料（50 Hz = 每 20ms 一筆）
    _timer = Timer.periodic(const Duration(milliseconds: 20), (_) {
      _generateMockData();
    });

    print('🔧 [Mock] 連接成功，開始生成資料（50 Hz）');
    return true;
  }

  /// 模擬斷開連接
  Future<void> disconnect() async {
    _timer?.cancel();
    _timer = null;
    print('🔧 [Mock] 已斷開連接');
  }

  /// 生成模擬感測器資料
  void _generateMockData() {
    final now = DateTime.now();
    final time = now.millisecondsSinceEpoch / 1000.0; // 轉換為秒

    // ==================== ICM-20948 九軸 IMU ====================

    // 加速度計（模擬靜止狀態 + 微小震動）
    // 範圍：約 ±2g = ±32768 / 16 = ±2048 LSB/g
    final accX = _simulateWithNoise(0, 50);
    final accY = _simulateWithNoise(0, 50);
    final accZ = _simulateWithNoise(16384, 100); // Z 軸約 1g（靜止朝上）

    // 陀螺儀（模擬微小旋轉 + 噪音）
    // 範圍：約 ±250 dps = ±32768 / 131 = ±250 LSB/dps
    final gyroX = _simulateWithNoise(0, 30);
    final gyroY = _simulateWithNoise(0, 30);
    final gyroZ = _simulateWithNoise(0, 30);

    // 磁力計（模擬地磁場）
    // 範圍：約 ±4900 µT
    final magX = _simulateWithNoise(200, 50);
    final magY = _simulateWithNoise(100, 50);
    final magZ = _simulateWithNoise(-300, 50);

    // ==================== MLX90393 磁力計 ====================

    // 模擬手指彎曲動作（正弦波 + 噪音）
    // 每個 MLX 代表一個手指關節的磁場變化
    final finger0Angle = sin(time * 0.5) * 1000 + 32768; // 拇指
    final finger1Angle = sin(time * 0.6 + 1.0) * 1200 + 32768; // 食指
    final finger2Angle = sin(time * 0.7 + 2.0) * 1100 + 32768; // 中指
    final finger3Angle = sin(time * 0.8 + 3.0) * 1000 + 32768; // 無名指

    final mlx0X = _clampUint16(finger0Angle + _randomNoise(100));
    final mlx0Y = _clampUint16(32768.0 + _randomNoise(200));
    final mlx0Z = _clampUint16(32768.0 + _randomNoise(150));

    final mlx1X = _clampUint16(finger1Angle + _randomNoise(100));
    final mlx1Y = _clampUint16(32768.0 + _randomNoise(200));
    final mlx1Z = _clampUint16(32768.0 + _randomNoise(150));

    final mlx2X = _clampUint16(finger2Angle + _randomNoise(100));
    final mlx2Y = _clampUint16(32768.0 + _randomNoise(200));
    final mlx2Z = _clampUint16(32768.0 + _randomNoise(150));

    final mlx3X = _clampUint16(finger3Angle + _randomNoise(100));
    final mlx3Y = _clampUint16(32768.0 + _randomNoise(200));
    final mlx3Z = _clampUint16(32768.0 + _randomNoise(150));

    // 建立資料實體
    final data = MlxSensorData(
      id: _idCounter++,
      deviceId: 'MOCK_DEVICE',
      time: now,
      accX: accX,
      accY: accY,
      accZ: accZ,
      gyroX: gyroX,
      gyroY: gyroY,
      gyroZ: gyroZ,
      magX: magX,
      magY: magY,
      magZ: magZ,
      mlx0X: mlx0X,
      mlx0Y: mlx0Y,
      mlx0Z: mlx0Z,
      mlx1X: mlx1X,
      mlx1Y: mlx1Y,
      mlx1Z: mlx1Z,
      mlx2X: mlx2X,
      mlx2Y: mlx2Y,
      mlx2Z: mlx2Z,
      mlx3X: mlx3X,
      mlx3Y: mlx3Y,
      mlx3Z: mlx3Z,
    );

    _dataController.add(data);
  }

  /// 模擬帶噪音的資料
  int _simulateWithNoise(int baseValue, int noiseRange) {
    return baseValue + _randomNoise(noiseRange);
  }

  /// 產生隨機噪音
  int _randomNoise(int range) {
    return _random.nextInt(range * 2) - range;
  }

  /// 限制在 uint16 範圍內 (0 ~ 65535)
  int _clampUint16(double value) {
    return value.clamp(0, 65535).toInt();
  }

  /// 模擬校正指令
  Future<bool> calibrate() async {
    print('🔧 [Mock] 執行校正指令');
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  /// 模擬初始化指令
  Future<bool> initialize() async {
    print('🔧 [Mock] 執行初始化指令');
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  /// 模擬重啟指令
  Future<bool> reset() async {
    print('🔧 [Mock] 執行重啟指令');
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  /// 釋放資源
  void dispose() {
    _timer?.cancel();
    _dataController.close();
  }
}
