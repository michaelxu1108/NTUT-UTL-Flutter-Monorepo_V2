import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:utl_amulet/application/amulet_entity_creator.dart';
import 'package:utl_amulet/domain/entity/recording_status.dart';

class AmuletFeaturesChangeNotifier extends ChangeNotifier {
  final AmuletEntityCreator amuletEntityCreator;
  late final StreamSubscription _subscription;
  late final StreamSubscription _statusSubscription;

  AmuletFeaturesChangeNotifier({required this.amuletEntityCreator}) {
    _subscription = amuletEntityCreator.isCreatingStream.listen(
      (_) => notifyListeners(),
    );
    _statusSubscription = amuletEntityCreator.recordingStatusStream.listen(
      (_) => notifyListeners(),
    );
  }

  bool get isSaving => amuletEntityCreator.isCreating;
  RecordingStatus get recordingStatus => amuletEntityCreator.recordingStatus;

  void toggleIsSaving() {
    return amuletEntityCreator.toggleCreating();
  }

  void setProcessingCsv() {
    amuletEntityCreator.setProcessingCsv();
  }

  void setCompleted() {
    amuletEntityCreator.setCompleted();
  }

  void reset() {
    amuletEntityCreator.reset();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _statusSubscription.cancel();
    super.dispose();
  }
}
