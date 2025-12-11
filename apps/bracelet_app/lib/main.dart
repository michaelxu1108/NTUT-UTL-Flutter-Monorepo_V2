import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/change_notifier/bracelet_change_notifier.dart';
import 'presentation/screen/home_screen.dart';
import 'infrastructure/source/bluetooth/mock_bracelet_bluetooth_module.dart';

/// ============================================
/// 模擬資料配置
/// MOCK DATA CONFIGURATION
/// ============================================
///
/// 設定說明 / Configuration:
/// - true:  使用模擬資料（適用於測試 UI，無需藍牙裝置）
///          Use mock data (for UI testing, no Bluetooth device needed)
/// - false: 使用真實藍牙裝置（需要實體手環裝置）
///          Use real Bluetooth device (physical bracelet required)
///
/// 建議 / Recommendation:
/// - 開發 UI 時設為 true（可立即看到資料流動效果）
///   Set to true when developing UI (see data flow immediately)
/// - 測試實體手環時設為 false
///   Set to false when testing with physical bracelet
///
const bool useMockData = true;

/// ============================================

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ============================================
    // 根據模擬模式創建相應的藍牙模組
    // Create appropriate Bluetooth module based on mock mode
    // ============================================

    if (useMockData) {
      // 模擬模式：使用 Mock 藍牙模組
      // Mock Mode: Use mock Bluetooth module
      debugPrint('🔧 執行模擬模式 - 使用模擬手環資料');
      debugPrint('🔧 Running in MOCK MODE - Using simulated bracelet data');
    } else {
      // 真實模式：使用真實藍牙模組
      // Real Mode: Use real Bluetooth module
      debugPrint('📱 執行藍牙模式 - 連接到真實手環裝置');
      debugPrint('📱 Running in BLUETOOTH MODE - Connecting to real bracelet');
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BraceletChangeNotifier(
            bluetoothModule: useMockData
                ? MockBraceletBluetoothModule() // 模擬模組
                : null, // null 會使用預設的 BraceletBluetoothModule
          ),
        ),
      ],
      child: MaterialApp(
        title: '手環感測器監控',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
