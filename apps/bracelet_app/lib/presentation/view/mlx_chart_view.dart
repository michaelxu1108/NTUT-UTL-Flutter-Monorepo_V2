import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../domain/entity/mlx_sensor_data.dart';

/// MLX 感測器即時波形圖
///
/// 使用 TabView 分組顯示 4 顆 MLX90393 的波形
/// 支援數值偏移功能
class MlxChartView extends StatefulWidget {
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
  State<MlxChartView> createState() => _MlxChartViewState();
}

class _MlxChartViewState extends State<MlxChartView> {
  // 偏移量設定（key: 'MLX0-X', 'MLX1-X', etc.）
  final Map<String, double> _offsets = {
    'MLX0-X': 0.0,
    'MLX1-X': 0.0,
    'MLX2-X': 0.0,
    'MLX3-X': 0.0,
  };

  // 是否顯示偏移控制面板
  bool _showOffsetControls = false;

  @override
  Widget build(BuildContext context) {
    // 取得最近的資料點
    final displayData = widget.dataList.length > widget.maxDataPoints
        ? widget.dataList.sublist(widget.dataList.length - widget.maxDataPoints)
        : widget.dataList;

    return DefaultTabController(
      length: 5, // 全部、MLX0、MLX1、MLX2、MLX3
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Tab 標籤列與偏移控制按鈕
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tab 標籤列
                  TabBar(
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
                  // 偏移控制按鈕
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _showOffsetControls = !_showOffsetControls;
                            });
                          },
                          icon: Icon(
                            _showOffsetControls ? Icons.expand_less : Icons.tune,
                            size: 16,
                          ),
                          label: Text(
                            _showOffsetControls ? '隱藏偏移控制' : '顯示偏移控制',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_showOffsetControls)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                for (var key in _offsets.keys) {
                                  _offsets[key] = 0.0;
                                }
                              });
                            },
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('重置', style: TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // 偏移控制面板（可滾動，限制最大高度）
                  if (_showOffsetControls)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 120),
                      child: SingleChildScrollView(
                        child: _buildOffsetControls(),
                      ),
                    ),
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

  /// 建立偏移控制面板
  Widget _buildOffsetControls() {
    return Container(
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOffsetRow('MLX0-X', 'MLX0 X軸偏移', Colors.blue),
          const SizedBox(height: 3),
          _buildOffsetRow('MLX1-X', 'MLX1 X軸偏移', Colors.red),
          const SizedBox(height: 3),
          _buildOffsetRow('MLX2-X', 'MLX2 X軸偏移', Colors.green),
          const SizedBox(height: 3),
          _buildOffsetRow('MLX3-X', 'MLX3 X軸偏移', Colors.orange),
        ],
      ),
    );
  }

  /// 建立單一偏移控制行
  Widget _buildOffsetRow(String key, String label, Color color) {
    return Row(
      children: [
        // 標籤
        Container(
          width: 85,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 6),
        // -100 按鈕
        _buildAdjustButton(key, -100, '-100'),
        // -10 按鈕
        _buildAdjustButton(key, -10, '-10'),
        // 顯示當前值
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              _offsets[key]!.toInt().toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ),
        // +10 按鈕
        _buildAdjustButton(key, 10, '+10'),
        // +100 按鈕
        _buildAdjustButton(key, 100, '+100'),
      ],
    );
  }

  /// 建立調整按鈕
  Widget _buildAdjustButton(String key, double delta, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.5),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _offsets[key] = _offsets[key]! + delta;
          });
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          minimumSize: const Size(45, 26),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(label, style: const TextStyle(fontSize: 10)),
      ),
    );
  }

  /// 顯示所有 MLX 的 X 軸數據（支援偏移）
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
            (d) => d.mlx0X.toDouble() + _offsets['MLX0-X']!,
            Colors.blue,
          ),
          _createLineSeries(
            data,
            'MLX1-X',
            (d) => d.mlx1X.toDouble() + _offsets['MLX1-X']!,
            Colors.red,
          ),
          _createLineSeries(
            data,
            'MLX2-X',
            (d) => d.mlx2X.toDouble() + _offsets['MLX2-X']!,
            Colors.green,
          ),
          _createLineSeries(
            data,
            'MLX3-X',
            (d) => d.mlx3X.toDouble() + _offsets['MLX3-X']!,
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

    // 為 X、Y、Z 軸使用高對比度的顏色，提高辨識度
    const xAxisColor = Color(0xFF2196F3); // 亮藍色
    const yAxisColor = Color(0xFFFF5722); // 深橙色
    const zAxisColor = Color(0xFF4CAF50); // 綠色

    List<CartesianSeries> series;
    switch (mlxIndex) {
      case 0:
        series = [
          _createLineSeries(data, 'X 軸', (d) => d.mlx0X.toDouble(), xAxisColor),
          _createLineSeries(data, 'Y 軸', (d) => d.mlx0Y.toDouble(), yAxisColor),
          _createLineSeries(data, 'Z 軸', (d) => d.mlx0Z.toDouble(), zAxisColor),
        ];
        break;
      case 1:
        series = [
          _createLineSeries(data, 'X 軸', (d) => d.mlx1X.toDouble(), xAxisColor),
          _createLineSeries(data, 'Y 軸', (d) => d.mlx1Y.toDouble(), yAxisColor),
          _createLineSeries(data, 'Z 軸', (d) => d.mlx1Z.toDouble(), zAxisColor),
        ];
        break;
      case 2:
        series = [
          _createLineSeries(data, 'X 軸', (d) => d.mlx2X.toDouble(), xAxisColor),
          _createLineSeries(data, 'Y 軸', (d) => d.mlx2Y.toDouble(), yAxisColor),
          _createLineSeries(data, 'Z 軸', (d) => d.mlx2Z.toDouble(), zAxisColor),
        ];
        break;
      case 3:
        series = [
          _createLineSeries(data, 'X 軸', (d) => d.mlx3X.toDouble(), xAxisColor),
          _createLineSeries(data, 'Y 軸', (d) => d.mlx3Y.toDouble(), yAxisColor),
          _createLineSeries(data, 'Z 軸', (d) => d.mlx3Z.toDouble(), zAxisColor),
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
