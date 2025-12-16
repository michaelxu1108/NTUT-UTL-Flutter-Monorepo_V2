import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utl_amulet/infrastructure/source/bluetooth/mock_bluetooth_module.dart';

/// Mock 版本的藍牙掃描器 - 顯示假設備並自動連接
///
/// 此版本用於假資料模式，不使用真實的藍牙掃描
class BluetoothScannerViewMock extends StatefulWidget {
  const BluetoothScannerViewMock({super.key});

  @override
  State<BluetoothScannerViewMock> createState() => _BluetoothScannerViewMockState();
}

class _BluetoothScannerViewMockState extends State<BluetoothScannerViewMock> {
  bool _isConnected = true; // Mock 設備預設為已連接

  @override
  void initState() {
    super.initState();
    // 顯示已自動連接的訊息
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎭 已自動連接到 Mock 設備'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _toggleConnection() {
    final mockModule = Provider.of<MockBluetoothModule>(context, listen: false);

    setState(() {
      _isConnected = !_isConnected;
    });

    if (_isConnected) {
      mockModule.startGeneratingData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已連接到 Mock 設備'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      mockModule.stopGeneratingData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已斷開 Mock 設備'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Devices (Mock Mode)'),
        backgroundColor: Colors.deepPurple.shade100,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.science, size: 16, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'MOCK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Mock 設備卡片
          Card(
            margin: const EdgeInsets.all(8),
            color: Colors.deepPurple.shade50,
            elevation: 4,
            child: ListTile(
              leading: Icon(
                Icons.science,
                color: Colors.deepPurple.shade700,
                size: 32,
              ),
              title: Text(
                MockBluetoothModule.mockDeviceName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(MockBluetoothModule.mockDeviceId),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sensors, size: 12, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          '50 Hz 假資料生成中',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: _toggleConnection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isConnected ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text(_isConnected ? 'Disconnect' : 'Connect'),
              ),
            ),
          ),
          // 說明卡片
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Mock 模式說明',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('資料來源', '自動生成的假資料'),
                  _buildInfoRow('更新頻率', '50 Hz (每 20ms)'),
                  _buildInfoRow('資料類型', '加速度、磁力計、姿態、溫度等'),
                  _buildInfoRow('模擬方式', '使用正弦波 + 隨機噪音'),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    '此模式用於測試，無需連接真實的藍牙設備。'
                    '所有感測器數據都是自動生成的模擬值。',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
