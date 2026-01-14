// 快速測試 SensorAxis 是否正確定義
import 'lib/domain/entity/sensor_axis.dart';

void main() {
  print('=== 測試 SensorAxis ===');
  print('總數量: ${SensorAxis.values.length}');
  print('');

  for (final category in SensorCategory.values) {
    print('${category.title}:');
    final axes = category.axes;
    print('  數量: ${axes.length}');
    for (final axis in axes) {
      print('  - ${axis.label}: ${axis.description}');
    }
    print('');
  }
}
