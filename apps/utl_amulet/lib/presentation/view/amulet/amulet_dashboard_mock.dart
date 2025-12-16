import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utl_amulet/l10n/gen_l10n/app_localizations.dart';

import '../../../domain/entity/amulet_entity.dart';
import '../../../service/data_stream/amulet_sensor_data_stream.dart';

class _Item extends StatelessWidget {
  final String label;
  final String data;
  const _Item({
    required this.label,
    required this.data,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            data,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ],
      ),
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

/// Mock 版本的 AmuletDashboard - 直接從數據流讀取，不依賴圖表管理器
class AmuletDashboardMock extends StatelessWidget {
  const AmuletDashboardMock({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final dataStream = context.read<AmuletSensorDataStream>();

    return StreamBuilder<AmuletSensorData>(
      stream: dataStream.dataStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Waiting for sensor data...'),
                SizedBox(height: 10),
                Text(
                  'Mock data will start generating in a moment',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 20),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: Text('No data available'),
          );
        }

        final sensorData = snapshot.data!;

        return Column(
          children: [
            Container(
              color: Colors.purple.shade50,
              padding: const EdgeInsets.all(8),
              child: const Row(
                children: [
                  Icon(Icons.science, size: 20, color: Colors.purple),
                  SizedBox(width: 8),
                  Text(
                    'Mock Data',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                children: [
                  _Item(label: appLocalizations.time, data: sensorData.time.toString().substring(11, 19)),
                  const Divider(),
                  _Item(label: appLocalizations.accX, data: sensorData.accX.toString()),
                  _Item(label: appLocalizations.accY, data: sensorData.accY.toString()),
                  _Item(label: appLocalizations.accZ, data: sensorData.accZ.toString()),
                  _Item(label: appLocalizations.accTotal, data: sensorData.accTotal.toString()),
                  const Divider(),
                  _Item(label: appLocalizations.roll, data: sensorData.roll.toString()),
                  _Item(label: appLocalizations.pitch, data: sensorData.pitch.toString()),
                  _Item(label: appLocalizations.yaw, data: sensorData.yaw.toString()),
                  const Divider(),
                  _Item(label: appLocalizations.magX, data: sensorData.magX.toString()),
                  _Item(label: appLocalizations.magY, data: sensorData.magY.toString()),
                  _Item(label: appLocalizations.magZ, data: sensorData.magZ.toString()),
                  _Item(label: appLocalizations.magTotal, data: sensorData.magTotal.toString()),
                  const Divider(),
                  _Item(label: appLocalizations.temperature, data: '${(sensorData.temperature / 100).toStringAsFixed(2)} °C'),
                  _Item(label: appLocalizations.posture, data: _postureTypeToString(sensorData.posture)),
                  _Item(label: appLocalizations.beaconRssi, data: '${sensorData.beaconRssi} dBm'),
                  _Item(label: appLocalizations.direction, data: '${sensorData.direction}°'),
                  _Item(label: appLocalizations.adc, data: sensorData.adc.toString()),
                  _Item(label: appLocalizations.battery, data: '${sensorData.battery}%'),
                  _Item(label: appLocalizations.area, data: sensorData.area.toString()),
                  _Item(label: appLocalizations.step, data: sensorData.step.toString()),
                  _Item(label: appLocalizations.point, data: sensorData.point.toString()),
                  _Item(label: appLocalizations.pressure, data: '${sensorData.pressure.toStringAsFixed(2)} hPa'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
