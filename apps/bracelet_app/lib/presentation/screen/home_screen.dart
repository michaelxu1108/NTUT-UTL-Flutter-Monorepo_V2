import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import '../change_notifier/bracelet_change_notifier.dart';
import '../view/control_panel_view.dart';
import '../view/sensor_selection_view.dart';
import '../view/dynamic_chart_view.dart';
import '../../domain/entity/sensor_axis.dart';
import '../../main.dart' show useMockData;

/// 主畫面
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 選中的感測器軸向
  Set<SensorAxis> _selectedAxes = {};

  @override
  void initState() {
    super.initState();

    // Mock 模式下自動連接
    if (useMockData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoConnectMockDevice(context);
      });
    }

    // 預設選擇一些軸向作為示範
    _selectedAxes = {
      SensorAxis.mlx0Z,
      SensorAxis.mlx1Z,
      SensorAxis.accX,
      SensorAxis.accY,
      SensorAxis.accZ,
    };
  }

  /// 切換軸向選擇
  void _toggleAxis(SensorAxis axis) {
    setState(() {
      if (_selectedAxes.contains(axis)) {
        _selectedAxes.remove(axis);
      } else {
        _selectedAxes.add(axis);
      }
    });
  }

  /// 全選
  void _selectAll() {
    setState(() {
      _selectedAxes = Set.from(SensorAxis.values);
    });
  }

  /// 清空選擇
  void _clearAll() {
    setState(() {
      _selectedAxes.clear();
    });
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
    // 側邊欄寬度
    final selectionWidth = constraints.maxWidth > 1200 ? 240.0 : 200.0;
    // 控制面板寬度
    final panelWidth = constraints.maxWidth > 1200 ? 280.0 : 240.0;

    return Row(
      children: [
        // 左側：感測器選擇側邊欄
        SizedBox(
          width: selectionWidth,
          child: SensorSelectionView(
            selectedAxes: _selectedAxes,
            onToggle: _toggleAxis,
            onSelectAll: _selectAll,
            onClearAll: _clearAll,
          ),
        ),
        // 中間：動態圖表
        Expanded(
          child: DynamicChartView(
            dataList: notifier.dataList,
            selectedAxes: _selectedAxes,
            maxDataPoints: 100,
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
        // 上方：感測器選擇（固定高度顯示）
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // 標題列
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.checklist, size: 18),
                    const SizedBox(width: 6),
                    const Text('選擇感測器', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_selectedAxes.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // 全選/清空按鈕
                    TextButton.icon(
                      onPressed: _selectAll,
                      icon: const Icon(Icons.select_all, size: 14),
                      label: const Text('全選', style: TextStyle(fontSize: 11)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton.icon(
                      onPressed: _clearAll,
                      icon: const Icon(Icons.clear_all, size: 14),
                      label: const Text('清空', style: TextStyle(fontSize: 11)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              // 感測器選擇列表（緊湊模式）
              Expanded(
                child: SensorSelectionView(
                  selectedAxes: _selectedAxes,
                  onToggle: _toggleAxis,
                  onSelectAll: _selectAll,
                  onClearAll: _clearAll,
                  showHeader: false,
                ),
              ),
            ],
          ),
        ),
        // 中間：動態圖表
        Expanded(
          flex: 5,
          child: DynamicChartView(
            dataList: notifier.dataList,
            selectedAxes: _selectedAxes,
            maxDataPoints: 100,
          ),
        ),
        // 下方：控制面板（緊湊版）
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: const SingleChildScrollView(
            child: ControlPanelView(),
          ),
        ),
      ],
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

    // 顯示連接狀態對話框
    final notifier = Provider.of<BraceletChangeNotifier>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConnectionStatusDialog(
        bluetoothModule: notifier,
        device: device,
      ),
    );
  }
}

/// 連接狀態對話框（顯示連接過程的詳細步驟）
class ConnectionStatusDialog extends StatefulWidget {
  final BraceletChangeNotifier bluetoothModule;
  final BluetoothDevice device;

  const ConnectionStatusDialog({
    super.key,
    required this.bluetoothModule,
    required this.device,
  });

  @override
  State<ConnectionStatusDialog> createState() => _ConnectionStatusDialogState();
}

class _ConnectionStatusDialogState extends State<ConnectionStatusDialog> {
  String _statusMessage = '準備連接...';
  bool _isError = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _startConnection();
  }

  void _startConnection() async {
    // 監聽連接狀態
    widget.bluetoothModule.connectionStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _statusMessage = status.message;
          _isError = status.isError;
          _isComplete = status.isComplete;
        });

        // 如果連接完成或發生錯誤，延遲後關閉對話框
        if (status.isComplete || status.isError) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);

              // 如果是錯誤，顯示詳細錯誤訊息
              if (status.isError) {
                _showErrorDialog(status.message);
              }
            }
          });
        }
      }
    });

    // 開始連接
    await widget.bluetoothModule.connectToDevice(widget.device);
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700]),
            const SizedBox(width: 12),
            const Text('連接失敗'),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            errorMessage,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24.0),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 圖示
              if (_isError)
                Icon(Icons.error_outline, size: 60, color: Colors.red[700])
              else if (_isComplete)
                Icon(Icons.check_circle_outline, size: 60, color: Colors.green[700])
              else
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              const SizedBox(height: 24),

              // 標題
              Text(
                _isError ? '連接失敗' : (_isComplete ? '連接成功！' : '連接中'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _isError
                      ? Colors.red[700]
                      : (_isComplete ? Colors.green[700] : null),
                ),
              ),
              const SizedBox(height: 16),

              // 狀態訊息
              Container(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
