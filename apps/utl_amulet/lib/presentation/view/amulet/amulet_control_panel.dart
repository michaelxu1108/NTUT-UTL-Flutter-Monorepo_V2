import 'package:flutter/material.dart';
import 'package:utl_amulet/l10n/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:utl_amulet/domain/repository/amulet_repository.dart';
import 'package:utl_amulet/domain/entity/recording_status.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:utl_amulet/presentation/theme/theme_data.dart';

import '../../../init/resource/infrastructure/bluetooth_resource.dart';
import '../../../service/file/file_handler.dart';
import '../../change_notifier/amulet/amulet_features_change_notifier.dart';
import '../../change_notifier/amulet/amulet_line_chart_change_notifier.dart';

/// 藍牙指令與數據記錄控制面板
class AmuletControlPanel extends StatelessWidget {
  const AmuletControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CSV 記錄控制區塊
          _buildDataRecordingSection(context),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          // 藍牙指令區塊
          const _BluetoothCommandSection(),
        ],
      ),
    );
  }

  Widget _buildDataRecordingSection(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final recordingStatus = context.select<AmuletFeaturesChangeNotifier, RecordingStatus>((f) => f.recordingStatus);
    final features = context.read<AmuletFeaturesChangeNotifier>();
    final fileHandler = context.read<FileHandler>();
    final repository = context.read<AmuletRepository>();
    final lineChartManager = context.read<AmuletLineChartManagerChangeNotifier>();

    VoidCallback? onPressed;

    // 根據狀態決定按鈕行為
    if (recordingStatus == RecordingStatus.recording) {
      // 錄製中 - 可以停止並匯出
      onPressed = () async {
        features.toggleIsSaving();
        lineChartManager.clear();

        // 設定為「製作 CSV 中」狀態
        features.setProcessingCsv();

        await fileHandler.downloadAmuletEntitiesFile(
          fetchEntitiesStream: repository.fetchEntities(),
          appLocalizations: appLocalizations,
        );
        await repository.clear();

        // 設定為「下載完成」狀態
        features.setCompleted();

        // 顯示完成對話框
        if (context.mounted) {
          _showCompletionDialog(context, appLocalizations);
        }
      };
    } else if (recordingStatus == RecordingStatus.idle || recordingStatus == RecordingStatus.completed) {
      // 閒置或已完成 - 可以開始新的錄製
      onPressed = () {
        if (recordingStatus == RecordingStatus.completed) {
          features.reset();
        }
        features.toggleIsSaving();
      };
    } else {
      // 處理中 - 禁用按鈕
      onPressed = null;
    }

    final themeData = Theme.of(context);

    // 根據狀態設定顏色和圖示
    Color color;
    IconData iconData;
    String statusText;
    String buttonText;

    switch (recordingStatus) {
      case RecordingStatus.recording:
        color = themeData.clearEnabledColor;
        iconData = Icons.stop;
        statusText = appLocalizations.recording;
        buttonText = appLocalizations.stopAndExportCSV;
        break;
      case RecordingStatus.processingCsv:
        color = Colors.orange;
        iconData = Icons.hourglass_empty;
        statusText = '製作 CSV 中';
        buttonText = '處理中...';
        break;
      case RecordingStatus.completed:
        color = Colors.blue;
        iconData = Icons.check_circle;
        statusText = '下載完成';
        buttonText = appLocalizations.startRecording;
        break;
      case RecordingStatus.idle:
        color = themeData.savingEnabledColor;
        iconData = Icons.play_arrow;
        statusText = appLocalizations.idle;
        buttonText = appLocalizations.startRecording;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.save_alt, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              appLocalizations.dataRecording,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusBackgroundColor(recordingStatus),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _getStatusBorderColor(recordingStatus),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              if (recordingStatus == RecordingStatus.processingCsv)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              else
                Icon(
                  _getStatusIcon(recordingStatus),
                  color: color,
                  size: 12,
                ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _getStatusTextColor(recordingStatus),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(iconData, size: 16),
            label: Text(
              buttonText,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            ),
          ),
        ),
        if (recordingStatus == RecordingStatus.recording) ...[
          const SizedBox(height: 6),
          Text(
            appLocalizations.stopRecordingHint,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (recordingStatus == RecordingStatus.completed) ...[
          const SizedBox(height: 6),
          Text(
            '✅ CSV 檔案已成功儲存！點擊開始按鈕進行下一次錄製',
            style: const TextStyle(fontSize: 10, color: Colors.blue),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Color _getStatusBackgroundColor(RecordingStatus status) {
    switch (status) {
      case RecordingStatus.recording:
        return Colors.green.shade50;
      case RecordingStatus.processingCsv:
        return Colors.orange.shade50;
      case RecordingStatus.completed:
        return Colors.blue.shade50;
      case RecordingStatus.idle:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusBorderColor(RecordingStatus status) {
    switch (status) {
      case RecordingStatus.recording:
        return Colors.green;
      case RecordingStatus.processingCsv:
        return Colors.orange;
      case RecordingStatus.completed:
        return Colors.blue;
      case RecordingStatus.idle:
        return Colors.grey.shade300;
    }
  }

  Color _getStatusTextColor(RecordingStatus status) {
    switch (status) {
      case RecordingStatus.recording:
        return Colors.green.shade700;
      case RecordingStatus.processingCsv:
        return Colors.orange.shade700;
      case RecordingStatus.completed:
        return Colors.blue.shade700;
      case RecordingStatus.idle:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon(RecordingStatus status) {
    switch (status) {
      case RecordingStatus.recording:
        return Icons.fiber_manual_record;
      case RecordingStatus.processingCsv:
        return Icons.hourglass_empty;
      case RecordingStatus.completed:
        return Icons.check_circle;
      case RecordingStatus.idle:
        return Icons.fiber_manual_record_outlined;
    }
  }

  void _showCompletionDialog(BuildContext context, AppLocalizations appLocalizations) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: '下載 CSV 完成',
      desc: 'CSV 檔案已成功儲存到您的裝置中！\n\n您可以繼續進行下一次錄製。',
      btnOkText: '確定',
      btnOkOnPress: () {
        // 對話框關閉後不需要做任何事
      },
      dismissOnTouchOutside: true,
      dismissOnBackKeyPress: true,
      btnOkColor: Colors.green,
    ).show();
  }
}

/// 藍牙指令輸入區塊
class _BluetoothCommandSection extends StatefulWidget {
  const _BluetoothCommandSection();

  @override
  State<_BluetoothCommandSection> createState() => _BluetoothCommandSectionState();
}

class _BluetoothCommandSectionState extends State<_BluetoothCommandSection> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;
  String? _lastCommand;
  bool? _lastCommandSuccess;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendCommand() async {
    final appLocalizations = AppLocalizations.of(context)!;
    final command = _controller.text.trim();
    if (command.isEmpty) {
      await Fluttertoast.showToast(msg: appLocalizations.pleaseEnterCommand);
      return;
    }

    setState(() {
      _isSending = true;
      _lastCommand = null;
      _lastCommandSuccess = null;
    });

    try {
      final success = await BluetoothResource.bluetoothModule.sendCommand(command: command);
      if (mounted) {
        setState(() {
          _lastCommand = command;
          _lastCommandSuccess = success;
        });
      }

      if (success) {
        await Fluttertoast.showToast(msg: appLocalizations.commandSent(command));
        _controller.clear();
      } else {
        await Fluttertoast.showToast(msg: appLocalizations.sendFailed);
      }
    } catch (e) {
      await Fluttertoast.showToast(msg: appLocalizations.errorOccurred(e.toString()));
      if (mounted) {
        setState(() {
          _lastCommand = command;
          _lastCommandSuccess = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bluetooth, color: Colors.blue, size: 16),
            const SizedBox(width: 6),
            Text(
              appLocalizations.bluetoothCommand,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 指令輸入框
        Row(
          children: [
            const Text('0x', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !_isSending,
                decoration: InputDecoration(
                  hintText: appLocalizations.enterCommand,
                  hintStyle: const TextStyle(fontSize: 11),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  border: const OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 11),
                onSubmitted: (_) => _sendCommand(),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: _isSending ? null : _sendCommand,
              icon: _isSending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send, size: 18),
              tooltip: appLocalizations.sendCommand,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        // 上次指令狀態
        if (_lastCommand != null && _lastCommandSuccess != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _lastCommandSuccess! ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _lastCommandSuccess! ? Colors.green : Colors.red,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _lastCommandSuccess! ? Icons.check_circle : Icons.error,
                  size: 12,
                  color: _lastCommandSuccess! ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _lastCommandSuccess!
                        ? appLocalizations.lastCommandSuccess(_lastCommand!)
                        : appLocalizations.lastCommandFailed(_lastCommand!),
                    style: TextStyle(
                      fontSize: 10,
                      color: _lastCommandSuccess! ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        // 指令說明
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 12, color: Colors.blue.shade700),
                  const SizedBox(width: 4),
                  Text(
                    appLocalizations.commandDescription,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _buildCommandItem('60', appLocalizations.commandBLEMode),
              _buildCommandItem('61', appLocalizations.commandSetSitPosture),
              _buildCommandItem('62', appLocalizations.commandSetStandPosture),
              _buildCommandItem('63', appLocalizations.commandSetInitPosture),
              _buildCommandItem('64', appLocalizations.commandAccGyroCalibrate),
              _buildCommandItem('65', appLocalizations.commandMagnetometerCalibrate),
              _buildCommandItem('66', appLocalizations.commandLowHeadMode),
              _buildCommandItem('67', appLocalizations.commandBreathMode),
              _buildCommandItem('70', appLocalizations.commandBindBand),
              _buildCommandItem('71', appLocalizations.commandUnbindBand),
              const SizedBox(height: 6),
              Text(
                appLocalizations.commandExample,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.blue.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommandItem(String code, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              '0x$code',
              style: TextStyle(
                fontSize: 9,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              description,
              style: TextStyle(fontSize: 9, color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
