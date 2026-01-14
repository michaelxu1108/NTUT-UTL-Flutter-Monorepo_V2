import 'dart:async';

import 'package:utl_amulet/domain/repository/amulet_repository.dart';
import 'package:utl_amulet/service/data_stream/amulet_sensor_data_stream.dart';
import 'package:utl_amulet/domain/entity/recording_status.dart';

import '../adapter/usecase/save_amulet_sensor_data_to_repository_usecase.dart';

abstract class AmuletEntityCreator {
  bool get isCreating;
  Stream<bool> get isCreatingStream;
  RecordingStatus get recordingStatus;
  Stream<RecordingStatus> get recordingStatusStream;
  void startCreating();
  void stopCreating();
  void toggleCreating();
  void setProcessingCsv();
  void setCompleted();
  void reset();
}

class AmuletEntityCreatorImpl implements AmuletEntityCreator {
  final AmuletRepository amuletRepository;
  final AmuletSensorDataStream amuletSensorDataStream;
  final StreamController<bool> _controller = StreamController.broadcast();
  final StreamController<RecordingStatus> _statusController = StreamController.broadcast();
  late final StreamSubscription _subscription;
  bool _isCreating = false;
  RecordingStatus _recordingStatus = RecordingStatus.idle;

  AmuletEntityCreatorImpl({
    required this.amuletRepository,
    required this.amuletSensorDataStream,
  }) {
    final saveAmuletSensorDataToRepositoryUsecase = SaveAmuletSensorDataToRepositoryUsecase(
      amuletRepository: amuletRepository,
    );
    _subscription = amuletSensorDataStream.dataStream.listen((data) {
      if(!_isCreating) return;
      saveAmuletSensorDataToRepositoryUsecase(data: data);
    });
  }

  @override
  bool get isCreating => _isCreating;

  @override
  RecordingStatus get recordingStatus => _recordingStatus;

  void _updateStatus(RecordingStatus status) {
    _recordingStatus = status;
    _statusController.add(_recordingStatus);
  }

  @override
  void startCreating() {
    _isCreating = true;
    _controller.add(_isCreating);
    _updateStatus(RecordingStatus.recording);
  }

  @override
  void stopCreating() {
    _isCreating = false;
    _controller.add(_isCreating);
    // 停止時不直接設為 idle，而是等待 CSV 處理完成
  }

  @override
  void toggleCreating() {
    return (isCreating)
      ? stopCreating()
      : startCreating();
  }

  @override
  void setProcessingCsv() {
    _updateStatus(RecordingStatus.processingCsv);
  }

  @override
  void setCompleted() {
    _updateStatus(RecordingStatus.completed);
  }

  @override
  void reset() {
    _updateStatus(RecordingStatus.idle);
  }

  @override
  Stream<bool> get isCreatingStream => _controller.stream;

  @override
  Stream<RecordingStatus> get recordingStatusStream => _statusController.stream;

  void close() {
    _subscription.cancel();
    _controller.close();
    _statusController.close();
  }
}
