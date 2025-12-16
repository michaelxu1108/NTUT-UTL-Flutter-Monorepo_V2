import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_utils/path_provider_utils.dart';
import 'package:utl_amulet/infrastructure/service/data_stream/amulet_sensor_data_stream.dart';
import 'package:utl_amulet/infrastructure/repository/amulet_repository.dart';
import 'package:utl_amulet/infrastructure/service/file/file_handler.dart';
import 'package:utl_amulet/infrastructure/source/bluetooth/bluetooth_module.dart';
import 'package:utl_amulet/infrastructure/source/hive/hive_source_handler.dart';
import 'package:utl_amulet/init/application_persist.dart';
import 'package:utl_amulet/init/resource/data/data_resource.dart';
import 'package:utl_amulet/init/resource/infrastructure/bluetooth_resource.dart';
import 'package:utl_amulet/init/resource/infrastructure/hive_source.dart';
import 'package:utl_amulet/init/resource/infrastructure/path_resource.dart';
import 'package:utl_amulet/init/resource/service/service_resource.dart';

class Initializer {
  final dynamic bluetoothModule;

  Initializer({
    this.bluetoothModule,
  });

  Future call() async {
    // 只在非 Mock 模式下設置 FlutterBluePlus
    if (bluetoothModule == null) {
      try {
        FlutterBluePlus.setLogLevel(LogLevel.none);
      } catch (e) {
        debugPrint('[INITIALIZER] Warning: Failed to set FlutterBluePlus log level: $e');
      }
    }

    BluetoothResource.bluetoothModule = bluetoothModule ?? BluetoothModule();

    PathResource.downloadPath = ((await getSystemDownloadDirectory()) ?? (await getApplicationDocumentsDirectory())).absolute.path;
    PathResource.hivePath = (await getApplicationDocumentsDirectory()).absolute.path;

    HiveSource.hiveSourceHandler = await HiveSourceHandler.init(
      hivePath: PathResource.hivePath,
    );

    DataResource.amuletRepository = AmuletRepositoryImpl(
      hiveSourceHandler: HiveSource.hiveSourceHandler,
    );

    ServiceResource.amuletSensorDataStream = AmuletSensorDataStreamImpl(
      bluetoothModule: BluetoothResource.bluetoothModule,
    );
    ServiceResource.fileHandler = FileHandlerImpl(
      amuletFileDownloadFolder: PathResource.downloadPath,
    );

    ApplicationPersist.init();
  }
}
