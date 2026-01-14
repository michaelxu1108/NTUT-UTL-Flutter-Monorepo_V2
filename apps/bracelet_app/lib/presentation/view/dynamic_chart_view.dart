import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../domain/entity/mlx_sensor_data.dart';
import '../../domain/entity/sensor_axis.dart';

/// 動態多選感測器圖表
///
/// 根據使用者選擇的軸向，動態顯示對應的波形
class DynamicChartView extends StatelessWidget {
  final List<MlxSensorData> dataList;
  final Set<SensorAxis> selectedAxes;
  final int maxDataPoints;

  const DynamicChartView({
    super.key,
    required this.dataList,
    required this.selectedAxes,
    this.maxDataPoints = 100,
  });

  @override
  Widget build(BuildContext context) {
    // 取得最近的資料點
    final displayData = dataList.length > maxDataPoints
        ? dataList.sublist(dataList.length - maxDataPoints)
        : dataList;

    // 如果沒有選擇任何軸向，顯示提示
    if (selectedAxes.isEmpty) {
      return _buildEmptyState(context);
    }

    // 如果沒有資料，顯示提示
    if (displayData.isEmpty) {
      return const Center(
        child: Text(
          '無資料',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SfCartesianChart(
          title: ChartTitle(
            text: '即時感測器波形',
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          legend: Legend(
            isVisible: true,
            position: LegendPosition.bottom,
            overflowMode: LegendItemOverflowMode.wrap,
            textStyle: const TextStyle(fontSize: 10),
          ),
          primaryXAxis: NumericAxis(
            title: AxisTitle(text: '資料點', textStyle: const TextStyle(fontSize: 11)),
            majorGridLines: const MajorGridLines(width: 0.5),
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(text: '數值', textStyle: const TextStyle(fontSize: 11)),
            majorGridLines: const MajorGridLines(width: 0.5),
          ),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            format: 'point.x : point.y',
          ),
          zoomPanBehavior: ZoomPanBehavior(
            enablePinching: true,
            enablePanning: true,
            zoomMode: ZoomMode.x,
          ),
          // 動態建立 Series
          series: _buildSeries(displayData),
        ),
      ),
    );
  }

  /// 建立空狀態提示
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '請選擇要顯示的感測器',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '從左側勾選列表中選擇',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// 根據選擇的軸向，動態建立 Series
  List<LineSeries<MlxSensorData, int>> _buildSeries(
    List<MlxSensorData> data,
  ) {
    final series = <LineSeries<MlxSensorData, int>>[];

    for (final axis in selectedAxes) {
      series.add(
        LineSeries<MlxSensorData, int>(
          name: axis.label,
          dataSource: data,
          xValueMapper: (MlxSensorData d, int index) => index,
          yValueMapper: (MlxSensorData d, _) => axis.getValue(d),
          color: axis.color,
          width: 2,
          markerSettings: const MarkerSettings(isVisible: false),
        ),
      );
    }

    return series;
  }
}
