part of 'mapper.dart';

double sensorDataTimeDifference({
  required DateTime startDateTime,
  required AmuletSensorData data,
}) {
  return (data.time.microsecondsSinceEpoch - startDateTime.microsecondsSinceEpoch) / 1e6;
}

num amuletLineChartItemToData({
  required AmuletLineChartItem item,
  required AmuletSensorData data,
}) {
  switch (item) {
    case AmuletLineChartItem.accX:
      return data.accX;
    case AmuletLineChartItem.accY:
      return data.accY;
    case AmuletLineChartItem.accZ:
      return data.accZ;
    case AmuletLineChartItem.accTotal:
      return data.accTotal;
    case AmuletLineChartItem.magX:
      return data.magX;
    case AmuletLineChartItem.magY:
      return data.magY;
    case AmuletLineChartItem.magZ:
      return data.magZ;
    case AmuletLineChartItem.magTotal:
      return data.magTotal;
    case AmuletLineChartItem.pitch:
      return data.pitch;
    case AmuletLineChartItem.roll:
      return data.roll;
    case AmuletLineChartItem.yaw:
      return data.yaw;
    case AmuletLineChartItem.pressure:
      return data.pressure;
    case AmuletLineChartItem.temperature:
      return data.temperature;
    case AmuletLineChartItem.posture:
      return data.posture.index;
    case AmuletLineChartItem.beaconRssi:
      return data.beaconRssi;
    case AmuletLineChartItem.point:
      return data.point;
    case AmuletLineChartItem.adc:
      return data.adc;
    case AmuletLineChartItem.battery:
      return data.battery;
    case AmuletLineChartItem.area:
      return data.area;
    case AmuletLineChartItem.step:
      return data.step;
    case AmuletLineChartItem.direction:
      return data.direction;
  }
}

List<Point<num>> _sensorDataDtoToDataSource({
  required Iterable<AmuletSensorData> dataList,
  required DateTime startDateTime,
  required AmuletLineChartItem item,
}) {
  return dataList.map((data) {
    num x = sensorDataTimeDifference(startDateTime: startDateTime, data: data);
    num y = amuletLineChartItemToData(item: item, data: data);
    return Point(x, y);
  }).toList();
}
