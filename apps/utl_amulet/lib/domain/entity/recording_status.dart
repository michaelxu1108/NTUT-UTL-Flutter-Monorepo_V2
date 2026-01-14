/// 數據記錄狀態
enum RecordingStatus {
  /// 閒置中 - 未在錄製
  idle,

  /// 錄製中 - 正在記錄數據
  recording,

  /// 製作 CSV 中 - 正在生成 CSV 檔案
  processingCsv,

  /// 下載完成 - CSV 已完成並儲存
  completed,
}

extension RecordingStatusExtension on RecordingStatus {
  /// 是否正在進行中（非閒置）
  bool get isActive => this != RecordingStatus.idle;

  /// 是否正在錄製
  bool get isRecording => this == RecordingStatus.recording;

  /// 是否正在處理 CSV
  bool get isProcessing => this == RecordingStatus.processingCsv;

  /// 是否已完成
  bool get isCompleted => this == RecordingStatus.completed;

  /// 是否可以開始新的錄製（閒置或已完成）
  bool get canStartRecording => this == RecordingStatus.idle || this == RecordingStatus.completed;
}
