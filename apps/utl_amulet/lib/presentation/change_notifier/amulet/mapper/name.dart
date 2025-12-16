part of 'mapper.dart';

String amuletLineChartItemToName({
  required AmuletLineChartItem item,
  required AppLocalizations appLocalizations,
}) {
  switch (item) {
    case AmuletLineChartItem.accX:
      return appLocalizations.accX;
    case AmuletLineChartItem.accY:
      return appLocalizations.accY;
    case AmuletLineChartItem.accZ:
      return appLocalizations.accZ;
    case AmuletLineChartItem.accTotal:
      return appLocalizations.accTotal;
    case AmuletLineChartItem.magX:
      return appLocalizations.magX;
    case AmuletLineChartItem.magY:
      return appLocalizations.magY;
    case AmuletLineChartItem.magZ:
      return appLocalizations.magZ;
    case AmuletLineChartItem.magTotal:
      return appLocalizations.magTotal;
    case AmuletLineChartItem.pitch:
      return appLocalizations.pitch;
    case AmuletLineChartItem.roll:
      return appLocalizations.roll;
    case AmuletLineChartItem.yaw:
      return appLocalizations.yaw;
    case AmuletLineChartItem.pressure:
      return appLocalizations.pressure;
    case AmuletLineChartItem.temperature:
      return appLocalizations.temperature;
    case AmuletLineChartItem.posture:
      return appLocalizations.posture;
    case AmuletLineChartItem.beaconRssi:
      return appLocalizations.beaconRssi;
    case AmuletLineChartItem.point:
      return appLocalizations.point;
    case AmuletLineChartItem.adc:
      return appLocalizations.adc;
    case AmuletLineChartItem.battery:
      return appLocalizations.battery;
    case AmuletLineChartItem.area:
      return appLocalizations.area;
    case AmuletLineChartItem.step:
      return appLocalizations.step;
    case AmuletLineChartItem.direction:
      return appLocalizations.direction;
  }
}
