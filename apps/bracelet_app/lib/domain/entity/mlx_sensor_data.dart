/// MLX90393 磁力計感測器資料實體
///
/// 包含：
/// - ICM-20948 九軸 IMU 資料（加速度、陀螺儀、磁力計）
/// - 4 顆 MLX90393 磁力計資料（I2C 位址 0x0C ~ 0x0F）
class MlxSensorData {
  /// 唯一識別碼（自動遞增）
  final int id;

  /// 裝置 ID（藍牙 MAC 位址）
  final String deviceId;

  /// 時間戳記
  final DateTime time;

  // ==================== ICM-20948 九軸 IMU ====================

  /// 加速度 X 軸（有符號 int16）
  final int accX;

  /// 加速度 Y 軸（有符號 int16）
  final int accY;

  /// 加速度 Z 軸（有符號 int16）
  final int accZ;

  /// 陀螺儀 X 軸（有符號 int16）
  final int gyroX;

  /// 陀螺儀 Y 軸（有符號 int16）
  final int gyroY;

  /// 陀螺儀 Z 軸（有符號 int16）
  final int gyroZ;

  /// 磁力計 X 軸（有符號 int16）
  final int magX;

  /// 磁力計 Y 軸（有符號 int16）
  final int magY;

  /// 磁力計 Z 軸（有符號 int16）
  final int magZ;

  // ==================== MLX90393 磁力計 0 (I2C 0x0C) ====================

  /// MLX0 X 軸（無符號 uint16）
  final int mlx0X;

  /// MLX0 Y 軸（無符號 uint16）
  final int mlx0Y;

  /// MLX0 Z 軸（無符號 uint16）
  final int mlx0Z;

  // ==================== MLX90393 磁力計 1 (I2C 0x0D) ====================

  /// MLX1 X 軸（無符號 uint16）
  final int mlx1X;

  /// MLX1 Y 軸（無符號 uint16）
  final int mlx1Y;

  /// MLX1 Z 軸（無符號 uint16）
  final int mlx1Z;

  // ==================== MLX90393 磁力計 2 (I2C 0x0E) ====================

  /// MLX2 X 軸（無符號 uint16）
  final int mlx2X;

  /// MLX2 Y 軸（無符號 uint16）
  final int mlx2Y;

  /// MLX2 Z 軸（無符號 uint16）
  final int mlx2Z;

  // ==================== MLX90393 磁力計 3 (I2C 0x0F) ====================

  /// MLX3 X 軸（無符號 uint16）
  final int mlx3X;

  /// MLX3 Y 軸（無符號 uint16）
  final int mlx3Y;

  /// MLX3 Z 軸（無符號 uint16）
  final int mlx3Z;

  MlxSensorData({
    required this.id,
    required this.deviceId,
    required this.time,
    required this.accX,
    required this.accY,
    required this.accZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.magX,
    required this.magY,
    required this.magZ,
    required this.mlx0X,
    required this.mlx0Y,
    required this.mlx0Z,
    required this.mlx1X,
    required this.mlx1Y,
    required this.mlx1Z,
    required this.mlx2X,
    required this.mlx2Y,
    required this.mlx2Z,
    required this.mlx3X,
    required this.mlx3Y,
    required this.mlx3Z,
  });

  /// 轉換成 CSV 格式的字串（參考圖片格式）
  ///
  /// 格式：時間,MLX0_X,MLX0_Y,MLX0_Z,MLX1_X,MLX1_Y,MLX1_Z,MLX2_X,MLX2_Y,MLX2_Z,MLX3_X,MLX3_Y,MLX3_Z
  String toCsvRow() {
    final timestamp = time.millisecondsSinceEpoch;
    return '$timestamp,$mlx0X,$mlx0Y,$mlx0Z,$mlx1X,$mlx1Y,$mlx1Z,$mlx2X,$mlx2Y,$mlx2Z,$mlx3X,$mlx3Y,$mlx3Z';
  }

  /// CSV 標頭行
  static String csvHeader() {
    return 'Timestamp,MLX0_X,MLX0_Y,MLX0_Z,MLX1_X,MLX1_Y,MLX1_Z,MLX2_X,MLX2_Y,MLX2_Z,MLX3_X,MLX3_Y,MLX3_Z';
  }
}
