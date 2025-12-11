import '../../../domain/entity/mlx_sensor_data.dart';
import 'hive_mlx_sensor.dart';

/// Hive 資料轉換器
class HiveMlxMapper {
  /// Domain Entity → Hive Model
  static HiveMlxSensor toHive(MlxSensorData entity) {
    return HiveMlxSensor(
      id: entity.id,
      deviceId: entity.deviceId,
      time: entity.time,
      accX: entity.accX,
      accY: entity.accY,
      accZ: entity.accZ,
      gyroX: entity.gyroX,
      gyroY: entity.gyroY,
      gyroZ: entity.gyroZ,
      magX: entity.magX,
      magY: entity.magY,
      magZ: entity.magZ,
      mlx0X: entity.mlx0X,
      mlx0Y: entity.mlx0Y,
      mlx0Z: entity.mlx0Z,
      mlx1X: entity.mlx1X,
      mlx1Y: entity.mlx1Y,
      mlx1Z: entity.mlx1Z,
      mlx2X: entity.mlx2X,
      mlx2Y: entity.mlx2Y,
      mlx2Z: entity.mlx2Z,
      mlx3X: entity.mlx3X,
      mlx3Y: entity.mlx3Y,
      mlx3Z: entity.mlx3Z,
    );
  }

  /// Hive Model → Domain Entity
  static MlxSensorData fromHive(HiveMlxSensor hive) {
    return MlxSensorData(
      id: hive.id,
      deviceId: hive.deviceId,
      time: hive.time,
      accX: hive.accX,
      accY: hive.accY,
      accZ: hive.accZ,
      gyroX: hive.gyroX,
      gyroY: hive.gyroY,
      gyroZ: hive.gyroZ,
      magX: hive.magX,
      magY: hive.magY,
      magZ: hive.magZ,
      mlx0X: hive.mlx0X,
      mlx0Y: hive.mlx0Y,
      mlx0Z: hive.mlx0Z,
      mlx1X: hive.mlx1X,
      mlx1Y: hive.mlx1Y,
      mlx1Z: hive.mlx1Z,
      mlx2X: hive.mlx2X,
      mlx2Y: hive.mlx2Y,
      mlx2Z: hive.mlx2Z,
      mlx3X: hive.mlx3X,
      mlx3Y: hive.mlx3Y,
      mlx3Z: hive.mlx3Z,
    );
  }

  /// 批次轉換：Hive List → Domain List
  static List<MlxSensorData> fromHiveList(List<HiveMlxSensor> hiveList) {
    return hiveList.map((hive) => fromHive(hive)).toList();
  }
}
