import 'dart:async';

import 'package:utl_amulet/infrastructure/source/bluetooth/bluetooth_received_packet.dart';
import 'package:utl_amulet/service/data_stream/amulet_sensor_data_stream.dart';

class AmuletSensorDataStreamImpl implements AmuletSensorDataStream {
  final dynamic bluetoothModule;

  AmuletSensorDataStreamImpl({
    required this.bluetoothModule,
  });

  @override
  Stream<AmuletSensorData> get dataStream {
    // 明確轉型以支援 BluetoothModule 和 MockBluetoothModule
    final Stream<BluetoothReceivedPacket> packetStream =
        bluetoothModule.onReceivePacket as Stream<BluetoothReceivedPacket>;

    return packetStream
      .map((packet) => packet.mapToData())
      .where((data) => data != null)
      .map((data) => data!);
  }
}
