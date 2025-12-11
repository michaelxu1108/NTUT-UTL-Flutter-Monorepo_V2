// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'UTL Amulet App';

  @override
  String downloadFileFinishedNotification(Object format) {
    return 'Download $format file finished.';
  }

  @override
  String get connectBluetoothButtonText => 'Connect';

  @override
  String get disconnectBluetoothButtonText => 'Disconnect';

  @override
  String get id => 'id';

  @override
  String get deviceId => 'device ID';

  @override
  String get time => 'time';

  @override
  String get accX => 'accX';

  @override
  String get accY => 'accY';

  @override
  String get accZ => 'accZ';

  @override
  String get accTotal => 'accTotal';

  @override
  String get gyroX => 'gyroX';

  @override
  String get gyroY => 'gyroY';

  @override
  String get gyroZ => 'gyroZ';

  @override
  String get gyroTotal => 'gyroTotal';

  @override
  String get magX => 'magX';

  @override
  String get magY => 'magY';

  @override
  String get magZ => 'magZ';

  @override
  String get magTotal => 'magTotal';

  @override
  String get pitch => 'pitch';

  @override
  String get roll => 'roll';

  @override
  String get yaw => 'yaw';

  @override
  String get gValue => 'gValue';

  @override
  String get pressure => 'pressure';

  @override
  String get temperature => 'temperature';

  @override
  String get posture => 'posture';

  @override
  String get adc => 'adc';

  @override
  String get battery => 'battery';

  @override
  String get area => 'area';

  @override
  String get step => 'step';

  @override
  String get direction => 'direction';
}
