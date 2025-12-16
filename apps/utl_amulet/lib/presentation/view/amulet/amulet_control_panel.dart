import 'package:flutter/material.dart';
import 'package:utl_amulet/l10n/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:utl_amulet/domain/repository/amulet_repository.dart';

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
    final isSaving = context.select<AmuletFeaturesChangeNotifier, bool>((f) => f.isSaving);
    final features = context.read<AmuletFeaturesChangeNotifier>();
    final fileHandler = context.read<FileHandler>();
    final repository = context.read<AmuletRepository>();
    final lineChartManager = context.read<AmuletLineChartManagerChangeNotifier>();

    VoidCallback? onPressed = (isSaving)
      ? () async {
        features.toggleIsSaving();
        lineChartManager.clear();
        await fileHandler.downloadAmuletEntitiesFile(
          fetchEntitiesStream: repository.fetchEntities(),
          appLocalizations: appLocalizations,
        );
        await repository.clear();
        await Fluttertoast.showToast(
          msg: appLocalizations.downloadFileFinishedNotification('CSV'),
        );
      }
      : features.toggleIsSaving;

    final themeData = Theme.of(context);
    final color = (isSaving)
        ? themeData.clearEnabledColor
        : themeData.savingEnabledColor;
    final iconData = (isSaving)
        ? Icons.stop
        : Icons.play_arrow;
    final statusText = (isSaving)
        ? appLocalizations.recording
        : appLocalizations.idle;
    final buttonText = (isSaving)
        ? appLocalizations.stopAndExportCSV
        : appLocalizations.startRecording;

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
            color: isSaving ? Colors.green.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSaving ? Colors.green : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSaving ? Icons.fiber_manual_record : Icons.fiber_manual_record_outlined,
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
                    color: isSaving ? Colors.green.shade700 : Colors.grey.shade600,
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
        if (isSaving) ...[
          const SizedBox(height: 6),
          Text(
            appLocalizations.stopRecordingHint,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
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
