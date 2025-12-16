class BluetoothResource {
  BluetoothResource._();
  static final List<String> sentUuids = [
    "6e400002-b5a3-f393-e0a9-e50e24dcca9e",
  ];
  static final List<String> receivedUuids = [
    "6e400003-b5a3-f393-e0a9-e50e24dcca9e",
  ];

  static dynamic _bluetoothModule;
  static dynamic get bluetoothModule {
    if (_bluetoothModule == null) {
      throw StateError('BluetoothResource not initialized. Call Initializer() first.');
    }
    return _bluetoothModule!;
  }
  static set bluetoothModule(dynamic value) {
    _bluetoothModule = value;
  }
}
