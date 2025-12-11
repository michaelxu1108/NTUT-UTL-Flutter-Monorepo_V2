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
  String get tabBluetoothScanner => 'BT Scan';

  @override
  String get tabDataList => 'Data';

  @override
  String get tabControlPanel => 'Control';

  @override
  String get dataRecording => 'Data Recording';

  @override
  String get recording => 'Recording...';

  @override
  String get idle => 'Idle';

  @override
  String get stopAndExportCSV => 'Stop & Export CSV';

  @override
  String get startRecording => 'Start Recording';

  @override
  String get stopRecordingHint => 'Tip: CSV will auto-export after stopping';

  @override
  String get bluetoothCommand => 'BT Command';

  @override
  String get enterCommand => 'Enter command...';

  @override
  String get sendCommand => 'Send';

  @override
  String get pleaseEnterCommand => 'Please enter command';

  @override
  String commandSent(String command) {
    return 'Command sent: 0x$command';
  }

  @override
  String get sendFailed => 'Send failed';

  @override
  String errorOccurred(String error) {
    return 'Error: $error';
  }

  @override
  String lastCommandSuccess(String command) {
    return 'Last: 0x$command (OK)';
  }

  @override
  String lastCommandFailed(String command) {
    return 'Last: 0x$command (Failed)';
  }

  @override
  String get commandDescription => 'Commands';

  @override
  String get commandExample => 'Example: 70D612D90003C5';

  @override
  String get commandBLEMode => 'BLE Mode';

  @override
  String get commandSetParam => 'Set Param';

  @override
  String get commandCalibrate => 'Calibrate';

  @override
  String get commandMagnetometer => 'Magnetometer';

  @override
  String get commandLowHeadMode => 'Low Head Mode';

  @override
  String get commandBreathMode => 'Breath Mode';

  @override
  String get commandBindBand => 'Bind Band';

  @override
  String get commandUnbindBand => 'Unbind Band';

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
  String get pressure => 'altitude';

  @override
  String get temperature => 'temperature';

  @override
  String get posture => 'posture';

  @override
  String get beaconRssi => 'beacon RSSI';

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

  @override
  String get point => 'point';
}
