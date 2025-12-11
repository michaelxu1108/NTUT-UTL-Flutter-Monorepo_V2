// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'UTL 平安符 App';

  @override
  String downloadFileFinishedNotification(Object format) {
    return '下载 $format 完成。';
  }

  @override
  String get connectBluetoothButtonText => '连接';

  @override
  String get disconnectBluetoothButtonText => '断开连接';

  @override
  String get id => 'id';

  @override
  String get deviceId => '设备 ID';

  @override
  String get time => '时间';

  @override
  String get accX => '加速度X';

  @override
  String get accY => '加速度Y';

  @override
  String get accZ => '加速度Z';

  @override
  String get accTotal => '加速度Total';

  @override
  String get gyroX => '陀螺仪X';

  @override
  String get gyroY => '陀螺仪Y';

  @override
  String get gyroZ => '陀螺仪Z';

  @override
  String get gyroTotal => '陀螺仪Total';

  @override
  String get magX => '磁场X';

  @override
  String get magY => '磁场Y';

  @override
  String get magZ => '磁场Z';

  @override
  String get magTotal => '磁场Total';

  @override
  String get pitch => '俯仰角';

  @override
  String get roll => '横滚角';

  @override
  String get yaw => '偏航角';

  @override
  String get gValue => '重力值';

  @override
  String get pressure => '气压';

  @override
  String get temperature => '温度';

  @override
  String get posture => '姿态';

  @override
  String get adc => '模数转换';

  @override
  String get battery => '电池';

  @override
  String get area => '区域';

  @override
  String get step => '步数';

  @override
  String get direction => '方向';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appName => 'UTL 平安符 App';

  @override
  String downloadFileFinishedNotification(Object format) {
    return '下載 $format 完成。';
  }

  @override
  String get connectBluetoothButtonText => '連接';

  @override
  String get disconnectBluetoothButtonText => '斷開連接';

  @override
  String get id => 'id';

  @override
  String get deviceId => '設備 ID';

  @override
  String get time => '時間';

  @override
  String get accX => '加速度X';

  @override
  String get accY => '加速度Y';

  @override
  String get accZ => '加速度Z';

  @override
  String get accTotal => '加速度Total';

  @override
  String get gyroX => '陀螺儀X';

  @override
  String get gyroY => '陀螺儀Y';

  @override
  String get gyroZ => '陀螺儀Z';

  @override
  String get gyroTotal => '陀螺儀Total';

  @override
  String get magX => '磁場X';

  @override
  String get magY => '磁場Y';

  @override
  String get magZ => '磁場Z';

  @override
  String get magTotal => '磁場Total';

  @override
  String get pitch => '俯仰角';

  @override
  String get roll => '橫滾角';

  @override
  String get yaw => '偏航角';

  @override
  String get gValue => '重力值';

  @override
  String get pressure => '氣壓';

  @override
  String get temperature => '溫度';

  @override
  String get posture => '姿態';

  @override
  String get adc => '模數轉換';

  @override
  String get battery => '電池';

  @override
  String get area => '區域';

  @override
  String get step => '步數';

  @override
  String get direction => '方向';
}
