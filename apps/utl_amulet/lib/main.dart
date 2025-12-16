import 'package:bluetooth_presentation/bluetooth_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:utl_amulet/l10n/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:utl_amulet/infrastructure/source/bluetooth/mock_bluetooth_module.dart';
import 'package:utl_amulet/init/initializer.dart';
import 'package:utl_amulet/presentation/change_notifier/amulet/amulet_features_change_notifier.dart';
import 'package:utl_amulet/presentation/change_notifier/amulet/amulet_line_chart_change_notifier.dart';
import 'package:utl_amulet/presentation/screen/home_screen.dart';
import 'package:utl_amulet/presentation/screen/home_screen_mock.dart';

import 'init/application_persist.dart';
import 'init/resource/data/data_resource.dart';
import 'init/resource/infrastructure/bluetooth_resource.dart';
import 'init/resource/service/service_resource.dart';

/// Mock 資料模式開關
///
/// true: 使用假資料模式 - 不需要藍牙設備，自動生成模擬數據
/// false: 正常模式 - 需要連接真實的藍牙設備
const bool useMockData = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 根據模式選擇不同的藍牙模組
  MockBluetoothModule? mockModule;
  if (useMockData) {
    mockModule = MockBluetoothModule();
    debugPrint('🎭 應用啟動 - Mock 資料模式');
    debugPrint('📱 Mock 設備: ${MockBluetoothModule.mockDeviceName}');
    debugPrint('🔢 Mock ID: ${MockBluetoothModule.mockDeviceId}');
  } else {
    debugPrint('📱 應用啟動 - 正常模式');
  }

  // 執行初始化並等待完成
  final initializer = Initializer(bluetoothModule: mockModule);
  await initializer();

  // 初始化完成後再啟動應用程式
  runApp(AppRoot(useMockData: useMockData, mockModule: mockModule));

  // 如果是 Mock 模式，延遲開始生成假資料，確保 UI 已經準備好
  if (useMockData && mockModule != null) {
    final module = mockModule; // 保存到局部變數以避免 null safety 問題
    Future.delayed(const Duration(milliseconds: 500), () {
      module.startGeneratingData();
      debugPrint('🟢 開始生成 Mock 資料');
    });
  }
}

class AppRoot extends StatelessWidget {
  final bool useMockData;
  final MockBluetoothModule? mockModule;

  const AppRoot({super.key, required this.useMockData, this.mockModule});

  @override
  Widget build(BuildContext context) {
    debugPrint('📱 AppRoot.build() 開始');
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('zh'), Locale('zh', 'TW')],
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: MultiProvider(
        providers: [
          // 如果是 Mock 模式，額外提供 MockBluetoothModule
          if (useMockData && mockModule != null)
            Provider<MockBluetoothModule>.value(value: mockModule!),
          Provider(create: (_) => BluetoothResource.bluetoothModule),
          Provider(create: (_) => DataResource.amuletRepository),
          Provider(create: (_) => ServiceResource.fileHandler),
          Provider(create: (_) => ServiceResource.amuletSensorDataStream),
          Provider(create: (_) => ApplicationPersist.amuletEntityCreator),
          ChangeNotifierProvider(
            create: (_) => AmuletFeaturesChangeNotifier(
              amuletEntityCreator: ApplicationPersist.amuletEntityCreator,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => AmuletLineChartManagerChangeNotifier(
              x: null,
              amuletSensorDataStream: ServiceResource.amuletSensorDataStream,
            ),
          ),
          Provider(
            create: (_) => BluetoothStatusController(
              onPressedButton: () async {
                try {
                  if (await fbp.FlutterBluePlus.isSupported == false) {
                    debugPrint("Bluetooth not supported by this device");
                    return;
                  }
                  await fbp.FlutterBluePlus.turnOn();
                } catch (e) {
                  debugPrint("Error turning on Bluetooth: $e");
                }
              },
            ),
          ),
        ],
        // 根據模式選擇不同的 HomeScreen
        child: useMockData ? const HomeScreenMock() : const HomeScreen(),
      ),
    );
  }
}
