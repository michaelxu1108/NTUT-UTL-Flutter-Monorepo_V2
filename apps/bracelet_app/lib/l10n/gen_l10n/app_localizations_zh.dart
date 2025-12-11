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
  String get tabBluetoothScanner => '蓝牙扫描';

  @override
  String get tabDataList => '数据列表';

  @override
  String get tabControlPanel => '控制面板';

  @override
  String get dataRecording => '数据记录';

  @override
  String get recording => '正在记录数据...';

  @override
  String get idle => '闲置中';

  @override
  String get stopAndExportCSV => '停止并导出 CSV';

  @override
  String get startRecording => '开始记录数据';

  @override
  String get stopRecordingHint => '提示：停止记录后将自动导出 CSV 文件';

  @override
  String get bluetoothCommand => '蓝牙指令';

  @override
  String get enterCommand => '输入指令...';

  @override
  String get sendCommand => '发送指令';

  @override
  String get pleaseEnterCommand => '请输入指令';

  @override
  String commandSent(String command) {
    return '指令已发送: 0x$command';
  }

  @override
  String get sendFailed => '发送失败';

  @override
  String errorOccurred(String error) {
    return '错误: $error';
  }

  @override
  String lastCommandSuccess(String command) {
    return '上次: 0x$command (成功)';
  }

  @override
  String lastCommandFailed(String command) {
    return '上次: 0x$command (失败)';
  }

  @override
  String get commandDescription => '指令说明';

  @override
  String get commandExample => '范例: 70D612D90003C5';

  @override
  String get commandBLEMode => 'BLE 模式';

  @override
  String get commandSetParam => '设定参数';

  @override
  String get commandCalibrate => '校正';

  @override
  String get commandMagnetometer => '磁力计';

  @override
  String get commandLowHeadMode => '低头模式';

  @override
  String get commandBreathMode => '呼吸模式';

  @override
  String get commandBindBand => '绑定手环';

  @override
  String get commandUnbindBand => '取消绑定';

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
  String get pressure => '高度';

  @override
  String get temperature => '温度';

  @override
  String get posture => '姿态';

  @override
  String get beaconRssi => '信标信号强度';

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

  @override
  String get point => '点位';
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
  String get tabBluetoothScanner => '藍牙掃描';

  @override
  String get tabDataList => '數據列表';

  @override
  String get tabControlPanel => '控制面板';

  @override
  String get dataRecording => '數據記錄';

  @override
  String get recording => '正在記錄數據...';

  @override
  String get idle => '閒置中';

  @override
  String get stopAndExportCSV => '停止並匯出 CSV';

  @override
  String get startRecording => '開始記錄數據';

  @override
  String get stopRecordingHint => '提示：停止記錄後將自動匯出 CSV 檔案';

  @override
  String get bluetoothCommand => '藍牙指令';

  @override
  String get enterCommand => '輸入指令...';

  @override
  String get sendCommand => '發送指令';

  @override
  String get pleaseEnterCommand => '請輸入指令';

  @override
  String commandSent(String command) {
    return '指令已發送: 0x$command';
  }

  @override
  String get sendFailed => '發送失敗';

  @override
  String errorOccurred(String error) {
    return '錯誤: $error';
  }

  @override
  String lastCommandSuccess(String command) {
    return '上次: 0x$command (成功)';
  }

  @override
  String lastCommandFailed(String command) {
    return '上次: 0x$command (失敗)';
  }

  @override
  String get commandDescription => '指令說明';

  @override
  String get commandExample => '範例: 70D612D90003C5';

  @override
  String get commandBLEMode => 'BLE 模式';

  @override
  String get commandSetParam => '設定參數';

  @override
  String get commandCalibrate => '校正';

  @override
  String get commandMagnetometer => '磁力計';

  @override
  String get commandLowHeadMode => '低頭模式';

  @override
  String get commandBreathMode => '呼吸模式';

  @override
  String get commandBindBand => '綁定手環';

  @override
  String get commandUnbindBand => '取消綁定';

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
  String get pressure => '高度';

  @override
  String get temperature => '溫度';

  @override
  String get posture => '姿態';

  @override
  String get beaconRssi => '信標信號強度';

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

  @override
  String get point => '點位';
}
