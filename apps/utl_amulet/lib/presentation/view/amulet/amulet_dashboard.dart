import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utl_amulet/l10n/gen_l10n/app_localizations.dart';

import '../../../domain/entity/amulet_entity.dart';
import '../../../service/data_stream/amulet_sensor_data_stream.dart';
import '../../change_notifier/amulet/amulet_line_chart_change_notifier.dart';
import '../../change_notifier/amulet/mapper/mapper.dart';

class _Item extends StatelessWidget {
  final String label;
  final String data;
  const _Item({
    required this.label,
    required this.data,
  });
  @override
  Widget build(BuildContext context) {
    return Text(
      "$label: $data",
    );
  }
}

String _postureTypeToString(AmuletPostureType posture) {
  switch (posture) {
    case AmuletPostureType.init:
      return 'Init (0)';
    case AmuletPostureType.sit:
      return 'Sit (1)';
    case AmuletPostureType.stand:
      return 'Stand (2)';
    case AmuletPostureType.lieDown:
      return 'Lie_Down (3)';
    case AmuletPostureType.lieDownRight:
      return 'Lie_Down_Right (4)';
    case AmuletPostureType.fallDown:
      return 'Fall_Down (5)';
    case AmuletPostureType.getDown:
      return 'Get_Down (6)';
    case AmuletPostureType.lieDownLeft:
      return 'Lie_Down_Left (7)';
    case AmuletPostureType.walk:
      return 'Walk (8)';
    case AmuletPostureType.reserved:
      return 'Reserved (9)';
    case AmuletPostureType.tempUnstable:
      return 'Temp_Unstable (10)';
    case AmuletPostureType.upright:
      return 'Upright (11)';
  }
}

class AmuletDashboard extends StatelessWidget {
  const AmuletDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final sensorData = context.select<AmuletLineChartManagerChangeNotifier, AmuletSensorData?>((m) {
      return (m.isTouched)
        ? m.getSensorDataByX()
        : m.getLastSensorData();
    });
    final x = context.select<AmuletLineChartManagerChangeNotifier, double?>((m) => m.getSensorX());
    final lineChartManager = context.read<AmuletLineChartManagerChangeNotifier>();
    final xLabel = lineChartManager.getXName();
    final xData = x?.toStringAsFixed(2) ?? "";
    return Column(
      children: [
        _Item(
          label: xLabel,
          data: xData,
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: AmuletLineChartItem.values.length,
            itemBuilder: (context, index) {
              final item = AmuletLineChartItem.values[index];
              final yLabel = lineChartManager.getItemName(item: item, appLocalizations: appLocalizations);
              String yData = "";
              if (sensorData != null) {
                if (item == AmuletLineChartItem.posture) {
                  // 顯示姿態名稱而不是數字
                  yData = _postureTypeToString(sensorData.posture);
                } else {
                  yData = lineChartManager.getData(data: sensorData, item: item).toStringAsFixed(2);
                }
              }
              return _Item(
                label: yLabel,
                data: yData,
              );
            },
          ),
        ),
      ],
    );
  }
}
