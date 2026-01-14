import 'package:hive/hive.dart';
import 'mlx_sensor_data.dart';

/// Hive TypeAdapter for MlxSensorData
///
/// 手動實作的 TypeAdapter，避免 code generation 版本衝突問題
class MlxSensorDataAdapter extends TypeAdapter<MlxSensorData> {
  @override
  final int typeId = 0;

  @override
  MlxSensorData read(BinaryReader reader) {
    return MlxSensorData(
      id: reader.readInt(),
      deviceId: reader.readString(),
      time: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      accX: reader.readInt(),
      accY: reader.readInt(),
      accZ: reader.readInt(),
      gyroX: reader.readInt(),
      gyroY: reader.readInt(),
      gyroZ: reader.readInt(),
      magX: reader.readInt(),
      magY: reader.readInt(),
      magZ: reader.readInt(),
      mlx0X: reader.readInt(),
      mlx0Y: reader.readInt(),
      mlx0Z: reader.readInt(),
      mlx1X: reader.readInt(),
      mlx1Y: reader.readInt(),
      mlx1Z: reader.readInt(),
      mlx2X: reader.readInt(),
      mlx2Y: reader.readInt(),
      mlx2Z: reader.readInt(),
      mlx3X: reader.readInt(),
      mlx3Y: reader.readInt(),
      mlx3Z: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, MlxSensorData obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.deviceId);
    writer.writeInt(obj.time.millisecondsSinceEpoch);
    writer.writeInt(obj.accX);
    writer.writeInt(obj.accY);
    writer.writeInt(obj.accZ);
    writer.writeInt(obj.gyroX);
    writer.writeInt(obj.gyroY);
    writer.writeInt(obj.gyroZ);
    writer.writeInt(obj.magX);
    writer.writeInt(obj.magY);
    writer.writeInt(obj.magZ);
    writer.writeInt(obj.mlx0X);
    writer.writeInt(obj.mlx0Y);
    writer.writeInt(obj.mlx0Z);
    writer.writeInt(obj.mlx1X);
    writer.writeInt(obj.mlx1Y);
    writer.writeInt(obj.mlx1Z);
    writer.writeInt(obj.mlx2X);
    writer.writeInt(obj.mlx2Y);
    writer.writeInt(obj.mlx2Z);
    writer.writeInt(obj.mlx3X);
    writer.writeInt(obj.mlx3Y);
    writer.writeInt(obj.mlx3Z);
  }
}
