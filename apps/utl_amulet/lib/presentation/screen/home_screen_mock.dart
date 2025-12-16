import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utl_amulet/l10n/gen_l10n/app_localizations.dart';
import 'package:utl_amulet/presentation/view/amulet/amulet_control_panel.dart';
import 'package:utl_amulet/presentation/view/amulet/amulet_dashboard_mock.dart';
import 'package:utl_amulet/presentation/view/amulet/amulet_line_chart_list.dart';
import 'package:utl_amulet/presentation/view/bluetooth/bluetooth_scanner_view_mock.dart';

/// Mock 版本的 HomeScreen - 跳過藍牙適配器檢查
///
/// 此版本用於假資料模式，不檢查真實的藍牙狀態
class HomeScreenMock extends StatelessWidget {
  const HomeScreenMock({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🏠 HomeScreenMock.build() 開始');

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    debugPrint('🏠 HomeScreenMock 設置螢幕方向完成');

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        debugPrint('🏠 LayoutBuilder 開始: constraints=$constraints');

        final mediaQueryData = MediaQuery.of(context);
        debugPrint('🏠 MediaQuery 取得完成');

        final controllerWidth = min(constraints.maxWidth / 3, (constraints.maxWidth - mediaQueryData.viewInsets.horizontal));
        debugPrint('🏠 計算 controllerWidth: $controllerWidth');

        final appLocalizations = AppLocalizations.of(context);
        debugPrint('🏠 AppLocalizations 取得: ${appLocalizations != null}');

        if (appLocalizations == null) {
          debugPrint('❌ AppLocalizations 為 null!');
          return const Scaffold(
            body: Center(
              child: Text('Loading...'),
            ),
          );
        }

        debugPrint('🏠 開始創建子組件');
        const bluetoothScannerView = BluetoothScannerViewMock();
        const amuletDashboard = AmuletDashboardMock(); // 使用 Mock 版本
        const amuletControlPanel = AmuletControlPanel();
        const amuletLineChartList = AmuletLineChartList();
        debugPrint('🏠 子組件創建完成');

        // 定義 Tab 標題和對應的頁面
        debugPrint('🏠 開始創建 tabItems');
        final tabItems = [
          {'icon': Icons.bluetooth_searching_rounded, 'label': appLocalizations.tabBluetoothScanner, 'view': bluetoothScannerView},
          {'icon': Icons.list_alt, 'label': appLocalizations.tabDataList, 'view': amuletDashboard},
          {'icon': Icons.settings_input_antenna, 'label': appLocalizations.tabControlPanel, 'view': amuletControlPanel},
        ];
        debugPrint('🏠 tabItems 創建完成');

        debugPrint('🏠 開始創建 TabBar');
        final tabBar = TabBar(
          isScrollable: false,
          labelStyle: const TextStyle(fontSize: 9, height: 1.0),
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          indicatorPadding: EdgeInsets.zero,
          tabs: tabItems.map((item) {
            return Tab(
              height: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'] as IconData, size: 18),
                  const SizedBox(height: 2),
                  Text(
                    item['label'] as String,
                    style: const TextStyle(fontSize: 9),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
        );
        debugPrint('🏠 TabBar 創建完成');

        debugPrint('🏠 開始創建 TabBarView');
        final tabView = TabBarView(
          children: tabItems.map((item) => item['view'] as Widget).toList(),
        );
        debugPrint('🏠 TabBarView 創建完成');

        debugPrint('🏠 開始創建 DefaultTabController');
        final tabController = DefaultTabController(
          length: tabItems.length,
          child: Scaffold(
            appBar: tabBar,
            body: tabView,
          ),
        );
        debugPrint('🏠 DefaultTabController 創建完成');

        debugPrint('🏠 開始返回最終 Scaffold');

        // 顯示完整的左右分割佈局
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: <Widget>[
                // 左側：圖表列表
                const Expanded(
                  child: amuletLineChartList,
                ),
                const VerticalDivider(),
                // 右側：Tab 面板
                SizedBox(
                  width: controllerWidth,
                  child: tabController,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
