import 'package:hive/hive.dart';

// ignore: uri_has_not_been_generated
part 'hive_mlx_sensor.g.dart';

/// Hive 資料模型：MLX 感測器資料
@HiveType(typeId: 0)
class HiveMlxSensor extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String deviceId;

  @HiveField(2)
  DateTime time;

  // ICM-20948
  @HiveField(3)
  int accX;

  @HiveField(4)
  int accY;

  @HiveField(5)
  int accZ;

  @HiveField(6)
  int gyroX;

  @HiveField(7)
  int gyroY;

  @HiveField(8)
  int gyroZ;

  @HiveField(9)
  int magX;

  @HiveField(10)
  int magY;

  @HiveField(11)
  int magZ;

  // MLX0
  @HiveField(12)
  int mlx0X;

  @HiveField(13)
  int mlx0Y;

  @HiveField(14)
  int mlx0Z;

  // MLX1
  @HiveField(15)
  int mlx1X;

  @HiveField(16)
  int mlx1Y;

  @HiveField(17)
  int mlx1Z;

  // MLX2
  @HiveField(18)
  int mlx2X;

  @HiveField(19)
  int mlx2Y;

  @HiveField(20)
  int mlx2Z;

  // MLX3
  @HiveField(21)
  int mlx3X;

  @HiveField(22)
  int mlx3Y;

  @HiveField(23)
  int mlx3Z;

  HiveMlxSensor({
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
}
