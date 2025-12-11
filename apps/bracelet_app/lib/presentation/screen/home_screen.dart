import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import '../change_notifier/bracelet_change_notifier.dart';
import '../view/mlx_chart_view.dart';
import '../view/control_panel_view.dart';
import '../../main.dart' show useMockData;

/// 主畫面
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // Mock 模式下自動連接
    if (useMockData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoConnectMockDevice(context);
      });
    }
  }

  /// 自動連接 Mock 裝置（啟動時執行）
  void _autoConnectMockDevice(BuildContext context) async {
    final notifier = Provider.of<BraceletChangeNotifier>(context, listen: false);

    // 如果已經連接，就不再重複連接
    if (notifier.isConnected) return;

    // 建立假的 BluetoothDevice
    final mockDeviceId = '00:00:00:00:00:00';
    final mockDevice = BluetoothDevice.fromId(mockDeviceId);

    // 自動連接
    final success = await notifier.connectToDevice(mockDevice);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔧 自動連接成功！Mock 資料流已啟動'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('手環感測器監控'),
        actions: [
          // 藍牙掃描按鈕
          IconButton(
            icon: const Icon(Icons.bluetooth_searching),
            onPressed: () => _showDeviceScanner(context),
            tooltip: '搜尋手環',
          ),
          // 斷開連接按鈕
          Consumer<BraceletChangeNotifier>(
            builder: (context, notifier, child) {
              if (!notifier.isConnected) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.bluetooth_disabled),
                onPressed: () => _confirmDisconnect(context, notifier),
                tooltip: '斷開連接',
              );
            },
          ),
        ],
      ),
      body: Consumer<BraceletChangeNotifier>(
        builder: (context, notifier, child) {
          if (!notifier.isConnected) {
            return _buildWelcomeScreen(context);
          }

          // 使用 OrientationBuilder 和 LayoutBuilder 實現響應式佈局
          return OrientationBuilder(
            builder: (context, orientation) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isLandscape = orientation == Orientation.landscape ||
                      constraints.maxWidth > constraints.maxHeight;

                  if (isLandscape) {
                    // 橫版佈局：左側圖表，右側控制面板
                    return _buildLandscapeLayout(notifier, constraints);
                  } else {
                    // 垂直版佈局：上方圖表，下方控制面板
                    return _buildPortraitLayout(notifier);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  /// 橫版佈局（左右分割）
  Widget _buildLandscapeLayout(BraceletChangeNotifier notifier, BoxConstraints constraints) {
    // 根據螢幕寬度動態調整控制面板寬度
    final panelWidth = constraints.maxWidth > 1200 ? 400.0 : 320.0;

    return Row(
      children: [
        // 左側：圖表和數值卡片
        Expanded(
          child: Column(
            children: [
              // 數值卡片（簡潔顯示）
              _buildDataCards(notifier, isCompact: true),
              // 圖表
              Expanded(
                child: MlxChartView(
                  dataList: notifier.dataList,
                  title: 'MLX90393 即時波形',
                  maxDataPoints: 100,
                ),
              ),
            ],
          ),
        ),
        // 右側：控制面板
        SizedBox(
          width: panelWidth,
          child: const SingleChildScrollView(
            child: ControlPanelView(),
          ),
        ),
      ],
    );
  }

  /// 垂直版佈局（上下分割）
  Widget _buildPortraitLayout(BraceletChangeNotifier notifier) {
    return Column(
      children: [
        // 數值卡片
        _buildDataCards(notifier, isCompact: false),
        // 圖表
        Expanded(
          flex: 3,
          child: MlxChartView(
            dataList: notifier.dataList,
            title: 'MLX90393 即時波形',
            maxDataPoints: 100,
          ),
        ),
        // 控制面板
        Expanded(
          flex: 2,
          child: const SingleChildScrollView(
            child: ControlPanelView(),
          ),
        ),
      ],
    );
  }

  /// 數值卡片（顯示最新數據）
  Widget _buildDataCards(BraceletChangeNotifier notifier, {required bool isCompact}) {
    final latestData = notifier.latestData;

    if (latestData == null) {
      return const SizedBox.shrink();
    }

    if (isCompact) {
      // 橫版：單行顯示
      return Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            _buildMiniDataCard('MLX0', latestData.mlx0X, latestData.mlx0Y, latestData.mlx0Z, Colors.blue),
            _buildMiniDataCard('MLX1', latestData.mlx1X, latestData.mlx1Y, latestData.mlx1Z, Colors.red),
            _buildMiniDataCard('MLX2', latestData.mlx2X, latestData.mlx2Y, latestData.mlx2Z, Colors.green),
            _buildMiniDataCard('MLX3', latestData.mlx3X, latestData.mlx3Y, latestData.mlx3Z, Colors.orange),
          ],
        ),
      );
    } else {
      // 垂直版：網格顯示
      return Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            _buildDataCard('MLX0', latestData.mlx0X, latestData.mlx0Y, latestData.mlx0Z, Colors.blue),
            _buildDataCard('MLX1', latestData.mlx1X, latestData.mlx1Y, latestData.mlx1Z, Colors.red),
            _buildDataCard('MLX2', latestData.mlx2X, latestData.mlx2Y, latestData.mlx2Z, Colors.green),
            _buildDataCard('MLX3', latestData.mlx3X, latestData.mlx3Y, latestData.mlx3Z, Colors.orange),
          ],
        ),
      );
    }
  }

  /// 迷你數據卡片（橫版用）
  Widget _buildMiniDataCard(String title, int x, int y, int z, Color color) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text('X:$x', style: const TextStyle(fontSize: 10)),
              Text('Y:$y', style: const TextStyle(fontSize: 10)),
              Text('Z:$z', style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  /// 數據卡片（垂直版用）
  Widget _buildDataCard(String title, int x, int y, int z, Color color) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text('X: $x', style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 4),
              Text('Y: $y', style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 4),
              Text('Z: $z', style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  /// 歡迎畫面（未連接狀態）
  Widget _buildWelcomeScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_disabled,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            '尚未連接手環',
            style: TextStyle(fontSize: 24, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showDeviceScanner(context),
            icon: const Icon(Icons.bluetooth_searching),
            label: const Text('搜尋手環'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  /// 顯示裝置掃描對話框
  void _showDeviceScanner(BuildContext context) {
    if (useMockData) {
      // Mock 模式：直接模擬連接
      _connectMockDevice(context);
    } else {
      // 真實模式：顯示藍牙掃描對話框
      showDialog(
        context: context,
        builder: (context) => const DeviceScannerDialog(),
      );
    }
  }

  /// 模擬連接（Mock 模式專用）
  void _connectMockDevice(BuildContext context) async {
    // 顯示連接中
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('連接中...（模擬模式）'),
              ],
            ),
          ),
        ),
      ),
    );

    // 建立假的 BluetoothDevice（用於 Mock 模式）
    // 注意：這裡我們需要創建一個假的裝置 ID
    final mockDeviceId = '00:00:00:00:00:00'; // Mock MAC 位址
    final mockDevice = BluetoothDevice.fromId(mockDeviceId);

    // 連接裝置
    final notifier = Provider.of<BraceletChangeNotifier>(context, listen: false);
    final success = await notifier.connectToDevice(mockDevice);

    if (context.mounted) {
      Navigator.pop(context); // 關閉連接中對話框

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '🔧 模擬連接成功！資料流已啟動' : '連接失敗'),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 確認斷開連接
  void _confirmDisconnect(BuildContext context, BraceletChangeNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認斷開連接'),
        content: const Text('確定要斷開與手環的連接嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await notifier.disconnect();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已斷開連接')),
                );
              }
            },
            child: const Text('確定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// 藍牙裝置掃描對話框
class DeviceScannerDialog extends StatefulWidget {
  const DeviceScannerDialog({super.key});

  @override
  State<DeviceScannerDialog> createState() => _DeviceScannerDialogState();
}

class _DeviceScannerDialogState extends State<DeviceScannerDialog> {
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  void _startScan() async {
    setState(() {
      _isScanning = true;
      _devices.clear();
    });

    // 開始掃描
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    // 監聽掃描結果
    FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          _devices = results.map((r) => r.device).toList();
        });
      }
    });

    // 掃描結束
    await Future.delayed(const Duration(seconds: 10));
    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('搜尋手環'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: _isScanning && _devices.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  final device = _devices[index];
                  return ListTile(
                    leading: const Icon(Icons.bluetooth),
                    title: Text(device.platformName.isEmpty ? '未命名裝置' : device.platformName),
                    subtitle: Text(device.remoteId.toString()),
                    onTap: () => _connectToDevice(context, device),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        if (!_isScanning)
          TextButton(
            onPressed: _startScan,
            child: const Text('重新掃描'),
          ),
      ],
    );
  }

  void _connectToDevice(BuildContext context, BluetoothDevice device) async {
    Navigator.pop(context); // 關閉對話框

    // 顯示連接中
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('連接中...'),
              ],
            ),
          ),
        ),
      ),
    );

    // 連接裝置
    final notifier = Provider.of<BraceletChangeNotifier>(context, listen: false);
    final success = await notifier.connectToDevice(device);

    if (context.mounted) {
      Navigator.pop(context); // 關閉連接中對話框

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '連接成功！' : '連接失敗'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
