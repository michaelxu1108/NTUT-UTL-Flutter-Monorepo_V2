enum AmuletPostureType {
  init,           // 0
  sit,            // 1
  stand,          // 2
  lieDown,        // 3
  lieDownRight,   // 4
  fallDown,       // 5
  getDown,        // 6
  lieDownLeft,    // 7
  walk,           // 8
  reserved,       // 9 (保留)
  tempUnstable,   // 10
  upright,        // 11
}

class AmuletEntity {
  final int id;
  final String deviceId;
  final DateTime time;
  final int accX;
  final int accY;
  final int accZ;
  final int accTotal;
  // final int gyroX;
  // final int gyroY;
  // final int gyroZ;
  // final int gyroTotal;
  final int magX;
  final int magY;
  final int magZ;
  final int magTotal;
  final int pitch;
  final int roll;
  final int yaw;
  // final int gValue;
  final double pressure;  // 改為 altitude (高度)
  final int temperature;
  final AmuletPostureType posture;
  final int beaconRssi;  // 新增 [27][28]
  final int adc;
  final int battery;
  final int area;
  final int step;
  final int direction;
  final int point;  // 新增 [36]

  AmuletEntity({
    required this.id,
    required this.deviceId,
    required this.time,
    required this.accX,
    required this.accY,
    required this.accZ,
    required this.accTotal,
    // required this.gyroX,
    // required this.gyroY,
    // required this.gyroZ,
    // required this.gyroTotal,
    required this.magX,
    required this.magY,
    required this.magZ,
    required this.magTotal,
    required this.pitch,
    required this.roll,
    required this.yaw,
    // required this.gValue,
    required this.pressure,
    required this.temperature,
    required this.posture,
    required this.beaconRssi,
    required this.adc,
    required this.battery,
    required this.area,
    required this.step,
    required this.direction,
    required this.point,
  });
}
