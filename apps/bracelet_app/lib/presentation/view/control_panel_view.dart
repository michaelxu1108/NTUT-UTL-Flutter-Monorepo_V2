import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../change_notifier/bracelet_change_notifier.dart';

/// 控制面板
///
/// 包含按鈕：
/// - 開始/暫停記錄
/// - 重置（清除資料和波形）
/// - 校正 IMU
/// - 初始化 IMU
/// - 重啟手環
/// - 匯出 CSV
class ControlPanelView extends StatelessWidget {
  const ControlPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BraceletChangeNotifier>(
      builder: (context, notifier, child) {
        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 標題
                const Text(
                  '控制面板',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // 連接狀態
                _buildStatusCard(notifier),
                const SizedBox(height: 16),

                // 記錄控制
                _buildRecordingControls(context, notifier),
                const SizedBox(height: 16),

                // 手環指令
                _buildDeviceCommands(context, notifier),
                const SizedBox(height: 16),

                // CSV 匯出
                _buildExportButton(context, notifier),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 狀態卡片
  Widget _buildStatusCard(BraceletChangeNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notifier.isConnected ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: notifier.isConnected ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                notifier.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                color: notifier.isConnected ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                notifier.isConnected ? '已連接' : '未連接',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: notifier.isConnected ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '資料筆數: ${notifier.dataCount}',
            style: const TextStyle(fontSize: 14),
          ),
          if (notifier.isRecording)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                '🔴 正在記錄',
                style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  /// 記錄控制按鈕
  Widget _buildRecordingControls(BuildContext context, BraceletChangeNotifier notifier) {
    return Column(
      children: [
        const Text(
          '記錄控制',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: notifier.isConnected ? () => notifier.toggleRecording() : null,
                icon: Icon(notifier.isRecording ? Icons.pause : Icons.play_arrow),
                label: Text(notifier.isRecording ? '暫停' : '開始'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: notifier.isRecording ? Colors.orange : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: notifier.dataCount > 0 ? () => _confirmReset(context, notifier) : null,
                icon: const Icon(Icons.refresh),
                label: const Text('重置'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 手環指令按鈕
  Widget _buildDeviceCommands(BuildContext context, BraceletChangeNotifier notifier) {
    return Column(
      children: [
        const Text(
          '手環指令',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: notifier.isConnected ? () => _sendCalibrate(context, notifier) : null,
              child: const Text('校正 IMU'),
            ),
            ElevatedButton(
              onPressed: notifier.isConnected ? () => _sendInitialize(context, notifier) : null,
              child: const Text('初始化 IMU'),
            ),
            ElevatedButton(
              onPressed: notifier.isConnected ? () => _confirmResetDevice(context, notifier) : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
              child: const Text('重啟手環'),
            ),
          ],
        ),
      ],
    );
  }

  /// CSV 匯出按鈕
  Widget _buildExportButton(BuildContext context, BraceletChangeNotifier notifier) {
    return ElevatedButton.icon(
      onPressed: notifier.dataCount > 0 && !notifier.isExporting
          ? () => _exportCsv(context, notifier)
          : null,
      icon: notifier.isExporting
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.file_download),
      label: Text(notifier.isExporting ? '匯出中...' : '匯出 CSV'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  // ==================== 動作處理 ====================

  /// 重置確認
  void _confirmReset(BuildContext context, BraceletChangeNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認重置'),
        content: Text('確定要清除所有資料嗎？\n目前有 ${notifier.dataCount} 筆資料。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              notifier.reset();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已重置')),
              );
            },
            child: const Text('確定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 發送校正指令
  void _sendCalibrate(BuildContext context, BraceletChangeNotifier notifier) async {
    final success = await notifier.calibrate();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? '校正指令已發送' : '校正指令發送失敗')),
      );
    }
  }

  /// 發送初始化指令
  void _sendInitialize(BuildContext context, BraceletChangeNotifier notifier) async {
    final success = await notifier.initialize();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? '初始化指令已發送' : '初始化指令發送失敗')),
      );
    }
  }

  /// 重啟手環確認
  void _confirmResetDevice(BuildContext context, BraceletChangeNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認重啟'),
        content: const Text('確定要重啟手環嗎？\n手環將會斷開連接並重新啟動。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await notifier.resetDevice();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? '重啟指令已發送' : '重啟指令發送失敗')),
                );
              }
            },
            child: const Text('確定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 匯出 CSV
  void _exportCsv(BuildContext context, BraceletChangeNotifier notifier) async {
    final filePath = await notifier.exportCsv();

    if (context.mounted) {
      if (filePath != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('匯出成功'),
            content: Text('檔案已儲存至：\n$filePath'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('確定'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('匯出失敗')),
        );
      }
    }
  }
}
