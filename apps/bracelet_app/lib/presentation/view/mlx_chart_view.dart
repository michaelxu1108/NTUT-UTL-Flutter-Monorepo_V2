import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../domain/entity/mlx_sensor_data.dart';

/// MLX 感測器即時波形圖
///
/// 使用 TabView 分組顯示 4 顆 MLX90393 的波形
class MlxChartView extends StatelessWidget {
  final List<MlxSensorData> dataList;
  final String title;
  final int maxDataPoints;

  const MlxChartView({
    super.key,
    required this.dataList,
    required this.title,
    this.maxDataPoints = 100, // 預設顯示最近 100 筆
  });

  @override
  Widget build(BuildContext context) {
    // 取得最近的資料點
    final displayData = dataList.length > maxDataPoints
        ? dataList.sublist(dataList.length - maxDataPoints)
        : dataList;

    return DefaultTabController(
      length: 5, // 全部、MLX0、MLX1、MLX2、MLX3
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Tab 標籤列
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: TabBar(
                isScrollable: true,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: const [
                  Tab(text: '全部'),
                  Tab(text: 'MLX0 (拇指)'),
                  Tab(text: 'MLX1 (食指)'),
                  Tab(text: 'MLX2 (中指)'),
                  Tab(text: 'MLX3 (無名指)'),
                ],
              ),
            ),
            // Tab 內容
            Expanded(
              child: TabBarView(
                children: [
                  _buildAllChart(displayData),
                  _buildSingleMlxChart(
                    displayData,
                    0,
                    'MLX0 (拇指)',
                    Colors.blue,
                  ),
                  _buildSingleMlxChart(displayData, 1, 'MLX1 (食指)', Colors.red),
                  _buildSingleMlxChart(
                    displayData,
                    2,
                    'MLX2 (中指)',
                    Colors.green,
                  ),
                  _buildSingleMlxChart(
                    displayData,
                    3,
                    'MLX3 (無名指)',
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 顯示所有 MLX 的 X 軸數據（簡化版）
  Widget _buildAllChart(List<MlxSensorData> data) {
    if (data.isEmpty) {
      return const Center(child: Text('無資料'));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SfCartesianChart(
        title: ChartTitle(text: '全部 MLX - X 軸數據'),
        legend: Legend(isVisible: true, position: LegendPosition.bottom),
        primaryXAxis: NumericAxis(
          title: AxisTitle(text: '資料點'),
          majorGridLines: const MajorGridLines(width: 0.5),
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: '數值'),
          majorGridLines: const MajorGridLines(width: 0.5),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        zoomPanBehavior: ZoomPanBehavior(
          enablePinching: true,
          enablePanning: true,
          zoomMode: ZoomMode.x,
        ),
        series: [
          _createLineSeries(
            data,
            'MLX0-X',
            (d) => d.mlx0X.toDouble(),
            Colors.blue,
          ),
          _createLineSeries(
            data,
            'MLX1-X',
            (d) => d.mlx1X.toDouble(),
            Colors.red,
          ),
          _createLineSeries(
            data,
            'MLX2-X',
            (d) => d.mlx2X.toDouble(),
            Colors.green,
          ),
          _createLineSeries(
            data,
            'MLX3-X',
            (d) => d.mlx3X.toDouble(),
            Colors.orange,
          ),
        ],
      ),
    );
  }

  /// 顯示單一 MLX 的 3 軸數據
  Widget _buildSingleMlxChart(
    List<MlxSensorData> data,
    int mlxIndex,
    String title,
    Color color,
  ) {
    if (data.isEmpty) {
      return const Center(child: Text('無資料'));
    }

    List<CartesianSeries> series;
    switch (mlxIndex) {
      case 0:
        series = [
          _createLineSeries(data, 'X 軸', (d) => d.mlx0X.toDouble(), color),
          _createLineSeries(
            data,
            'Y 軸',
            (d) => d.mlx0Y.toDouble(),
            color.withValues(alpha: 0.7),
          ),
          _createLineSeries(
            data,
            'Z 軸',
            (d) => d.mlx0Z.toDouble(),
            color.withValues(alpha: (0.4)),
          ),
        ];
        break;
      case 1:
        series = [
          _createLineSeries(data, 'X 軸', (d) => d.mlx1X.toDouble(), color),
          _createLineSeries(
            data,
            'Y 軸',
            (d) => d.mlx1Y.toDouble(),
            color.withValues(alpha: 0.7),
          ),
          _createLineSeries(
            data,
            'Z 軸',
            (d) => d.mlx1Z.toDouble(),
            color.withValues(alpha: (0.4)),
          ),
        ];
        break;
      case 2:
        series = [
          _createLineSeries(data, 'X 軸', (d) => d.mlx2X.toDouble(), color),
          _createLineSeries(
            data,
            'Y 軸',
            (d) => d.mlx2Y.toDouble(),
            color.withValues(alpha: 0.7),
          ),
          _createLineSeries(
            data,
            'Z 軸',
            (d) => d.mlx2Z.toDouble(),
            color.withValues(alpha: 0.4),
          ),
        ];
        break;
      case 3:
        series = [
          _createLineSeries(data, 'X 軸', (d) => d.mlx3X.toDouble(), color),
          _createLineSeries(
            data,
            'Y 軸',
            (d) => d.mlx3Y.toDouble(),
            color.withValues(alpha: 0.7),
          ),
          _createLineSeries(
            data,
            'Z 軸',
            (d) => d.mlx3Z.toDouble(),
            color.withValues(alpha: 0.4),
          ),
        ];
        break;
      default:
        series = [];
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SfCartesianChart(
        title: ChartTitle(text: title),
        legend: Legend(isVisible: true, position: LegendPosition.bottom),
        primaryXAxis: NumericAxis(
          title: AxisTitle(text: '資料點'),
          majorGridLines: const MajorGridLines(width: 0.5),
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: '數值'),
          majorGridLines: const MajorGridLines(width: 0.5),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        zoomPanBehavior: ZoomPanBehavior(
          enablePinching: true,
          enablePanning: true,
          zoomMode: ZoomMode.x,
        ),
        series: series,
      ),
    );
  }

  /// 建立單一折線圖
  LineSeries<MlxSensorData, int> _createLineSeries(
    List<MlxSensorData> data,
    String name,
    double Function(MlxSensorData) yValueMapper,
    Color color,
  ) {
    return LineSeries<MlxSensorData, int>(
      name: name,
      dataSource: data,
      xValueMapper: (MlxSensorData d, int index) => index,
      yValueMapper: (MlxSensorData d, _) => yValueMapper(d),
      color: color,
      width: 2,
      markerSettings: const MarkerSettings(isVisible: false),
    );
  }
}
