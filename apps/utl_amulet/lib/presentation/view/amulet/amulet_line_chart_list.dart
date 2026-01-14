import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../change_notifier/amulet/amulet_line_chart_change_notifier.dart';
import '../../change_notifier/amulet/amulet_line_chart_filtered_change_notifier.dart';
import '../../change_notifier/amulet/mapper/mapper.dart';

import 'amulet_line_chart.dart';

class AmuletLineChartList extends StatelessWidget {
  const AmuletLineChartList({super.key});
  Iterable<AmuletLineChartItem> _getItems() sync* {
    for(var item in AmuletLineChartItem.values) {
      switch(item) {
        // temperature 已移除，現在會顯示溫度圖表
        case AmuletLineChartItem.adc:
        case AmuletLineChartItem.battery:
        case AmuletLineChartItem.step:
        case AmuletLineChartItem.direction:
        case AmuletLineChartItem.area:
          continue;
        default:
          yield item;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    // 使用 Consumer 而不是 context.read，確保 Provider 已經完全初始化
    return Consumer<AmuletLineChartManagerChangeNotifier>(
      builder: (context, lineChartManager, _) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final height = constraints.maxHeight / 2.5;
            final items = _getItems().toList();
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => SizedBox(
                height: height,
                child: ChangeNotifierProvider(
                  create: (_) => AmuletLineChartFilteredChangeNotifier(
                    items: [
                      items.elementAt(index),
                    ],
                    amuletLineChartManagerChangeNotifier: lineChartManager,
                  ),
                  child: const AmuletLineChart(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
