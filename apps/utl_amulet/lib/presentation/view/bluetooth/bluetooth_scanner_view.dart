import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

class BluetoothScannerView extends StatefulWidget {
  const BluetoothScannerView({super.key});

  @override
  State<BluetoothScannerView> createState() => _BluetoothScannerViewState();
}

class _BluetoothScannerViewState extends State<BluetoothScannerView> {
  List<fbp.ScanResult> _scanResults = [];
  List<fbp.BluetoothDevice> _connectedDevices = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _loadConnectedDevices();
    _startScan();
  }

  void _loadConnectedDevices() {
    // 獲取所有已連接的設備
    _connectedDevices = fbp.FlutterBluePlus.connectedDevices;
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _scanResults = [];
    });

    try {
      // Start scanning
      await fbp.FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

      // Listen to scan results
      fbp.FlutterBluePlus.scanResults.listen((results) {
        if (mounted) {
          setState(() {
            // 過濾掉 Unknown Device（沒有設備名稱的裝置）
            _scanResults = results.where((result) {
              return result.device.platformName.isNotEmpty;
            }).toList();
          });
        }
      });

      // Wait for scan to complete
      await fbp.FlutterBluePlus.isScanning.firstWhere((scanning) => !scanning);
    } catch (e) {
      debugPrint('Error during scan: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _stopScan() async {
    await fbp.FlutterBluePlus.stopScan();
    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _connectToDevice(fbp.BluetoothDevice device) async {
    try {
      await device.connect(license: fbp.License.free);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connected to device'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error connecting to device: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to connect'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 合併掃描結果和已連接設備
    final allDevices = <fbp.BluetoothDevice>[];
    final deviceIds = <String>{};

    // 先添加已連接的設備
    for (final device in _connectedDevices) {
      allDevices.add(device);
      deviceIds.add(device.remoteId.str);
    }

    // 再添加掃描結果中的設備（避免重複）
    for (final result in _scanResults) {
      if (!deviceIds.contains(result.device.remoteId.str)) {
        allDevices.add(result.device);
        deviceIds.add(result.device.remoteId.str);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Devices'),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.refresh),
            onPressed: () {
              if (_isScanning) {
                _stopScan();
              } else {
                _loadConnectedDevices();
                _startScan();
              }
            },
          ),
        ],
      ),
      body: _isScanning && allDevices.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: allDevices.length,
              itemBuilder: (context, index) {
                final device = allDevices[index];
                final deviceName = device.platformName.isEmpty
                    ? 'Unknown Device'
                    : device.platformName;

                return ListTile(
                  title: Text(deviceName),
                  subtitle: Text(device.remoteId.str),
                  trailing: StreamBuilder<fbp.BluetoothConnectionState>(
                    stream: device.connectionState,
                    initialData: fbp.BluetoothConnectionState.disconnected,
                    builder: (context, snapshot) {
                      final isConnected =
                          snapshot.data == fbp.BluetoothConnectionState.connected;

                      return ElevatedButton(
                        onPressed: isConnected
                            ? () => device.disconnect()
                            : () => _connectToDevice(device),
                        child: Text(isConnected ? 'Disconnect' : 'Connect'),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
