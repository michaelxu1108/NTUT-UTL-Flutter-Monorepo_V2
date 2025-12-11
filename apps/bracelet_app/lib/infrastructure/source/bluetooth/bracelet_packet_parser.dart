import 'dart:typed_data';
import '../../../domain/entity/mlx_sensor_data.dart';

/// 手環藍牙封包解析器
///
/// 封包格式（總長度 43 bytes）：
/// - Byte 0:      標頭 0x0A
/// - Byte 1-18:   ICM-20948 資料（9 個 int16 值）
///   - Byte 1-2:   AccX (有符號 int16, big endian)
///   - Byte 3-4:   AccY (有符號 int16, big endian)
///   - Byte 5-6:   AccZ (有符號 int16, big endian)
///   - Byte 7-8:   GyroX (有符號 int16, big endian)
///   - Byte 9-10:  GyroY (有符號 int16, big endian)
///   - Byte 11-12: GyroZ (有符號 int16, big endian)
///   - Byte 13-14: MagX (有符號 int16, big endian)
///   - Byte 15-16: MagY (有符號 int16, big endian)
///   - Byte 17-18: MagZ (有符號 int16, big endian)
/// - Byte 19-42:  4 顆 MLX90393 資料（12 個 uint16 值）
///   - Byte 19-20: MLX0 X (無符號 uint16, big endian)
///   - Byte 21-22: MLX0 Y (無符號 uint16, big endian)
///   - Byte 23-24: MLX0 Z (無符號 uint16, big endian)
///   - Byte 25-26: MLX1 X (無符號 uint16, big endian)
///   - Byte 27-28: MLX1 Y (無符號 uint16, big endian)
///   - Byte 29-30: MLX1 Z (無符號 uint16, big endian)
///   - Byte 31-32: MLX2 X (無符號 uint16, big endian)
///   - Byte 33-34: MLX2 Y (無符號 uint16, big endian)
///   - Byte 35-36: MLX2 Z (無符號 uint16, big endian)
///   - Byte 37-38: MLX3 X (無符號 uint16, big endian)
///   - Byte 39-40: MLX3 Y (無符號 uint16, big endian)
///   - Byte 41-42: MLX3 Z (無符號 uint16, big endian)
class BraceletPacketParser {
  static const int packetLength = 43;
  static const int packetHeader = 0x0A;

  static int _idCounter = 0;

  /// 解析藍牙封包
  ///
  /// 回傳 [MlxSensorData] 或 null（如果封包格式錯誤）
  static MlxSensorData? parse(List<int> data, String deviceId) {
    // 檢查封包長度
    if (data.length != packetLength) {
      print('封包長度錯誤: ${data.length} != $packetLength');
      return null;
    }

    // 檢查封包標頭
    if (data[0] != packetHeader) {
      print('封包標頭錯誤: 0x${data[0].toRadixString(16)} != 0x${packetHeader.toRadixString(16)}');
      return null;
    }

    try {
      final bytes = ByteData.sublistView(Uint8List.fromList(data));

      return MlxSensorData(
        id: _idCounter++,
        deviceId: deviceId,
        time: DateTime.now(),

        // ICM-20948: Byte 1-18 (有符號 int16)
        accX: bytes.getInt16(1, Endian.big),
        accY: bytes.getInt16(3, Endian.big),
        accZ: bytes.getInt16(5, Endian.big),
        gyroX: bytes.getInt16(7, Endian.big),
        gyroY: bytes.getInt16(9, Endian.big),
        gyroZ: bytes.getInt16(11, Endian.big),
        magX: bytes.getInt16(13, Endian.big),
        magY: bytes.getInt16(15, Endian.big),
        magZ: bytes.getInt16(17, Endian.big),

        // MLX0 (0x0C): Byte 19-24 (無符號 uint16)
        mlx0X: bytes.getUint16(19, Endian.big),
        mlx0Y: bytes.getUint16(21, Endian.big),
        mlx0Z: bytes.getUint16(23, Endian.big),

        // MLX1 (0x0D): Byte 25-30 (無符號 uint16)
        mlx1X: bytes.getUint16(25, Endian.big),
        mlx1Y: bytes.getUint16(27, Endian.big),
        mlx1Z: bytes.getUint16(29, Endian.big),

        // MLX2 (0x0E): Byte 31-36 (無符號 uint16)
        mlx2X: bytes.getUint16(31, Endian.big),
        mlx2Y: bytes.getUint16(33, Endian.big),
        mlx2Z: bytes.getUint16(35, Endian.big),

        // MLX3 (0x0F): Byte 37-42 (無符號 uint16)
        mlx3X: bytes.getUint16(37, Endian.big),
        mlx3Y: bytes.getUint16(39, Endian.big),
        mlx3Z: bytes.getUint16(41, Endian.big),
      );
    } catch (e) {
      print('封包解析錯誤: $e');
      return null;
    }
  }

  /// 重置 ID 計數器
  static void resetIdCounter() {
    _idCounter = 0;
  }
}
