import 'package:flutter/material.dart';
import '../../domain/entity/sensor_axis.dart';

/// 感測器選擇側邊欄
///
/// 提供多選勾選框，讓使用者選擇要顯示的感測器軸向
class SensorSelectionView extends StatelessWidget {
  final Set<SensorAxis> selectedAxes;
  final ValueChanged<SensorAxis> onToggle;
  final VoidCallback onSelectAll;
  final VoidCallback onClearAll;
  final bool showHeader;

  const SensorSelectionView({
    super.key,
    required this.selectedAxes,
    required this.onToggle,
    required this.onSelectAll,
    required this.onClearAll,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: showHeader
            ? Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              )
            : null,
      ),
      child: Column(
        children: [
          // 標題與操作按鈕（可選）
          if (showHeader) ...[
            _buildHeader(context),
            Divider(height: 1, color: Theme.of(context).dividerColor),
          ],

          // 勾選列表（可捲動）
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: [
                // 按分類顯示
                for (final category in SensorCategory.values)
                  _buildCategorySection(context, category),
              ],
            ),
          ),

          // 已選數量提示（可選）
          if (showHeader) _buildSelectionCounter(context),
        ],
      ),
    );
  }

  /// 建立標題與操作按鈕
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標題
          Row(
            children: [
              Icon(
                Icons.checklist,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '選擇感測器',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 操作按鈕
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSelectAll,
                  icon: const Icon(Icons.select_all, size: 16),
                  label: const Text('全選', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onClearAll,
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('清空', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 建立分類區塊
  Widget _buildCategorySection(BuildContext context, SensorCategory category) {
    final axes = category.axes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分類標題
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Row(
            children: [
              Icon(category.icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                category.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),

        // 該分類下的所有軸向
        ...axes.map((axis) => _buildCheckboxTile(context, axis)),

        // 間距
        const SizedBox(height: 4),
      ],
    );
  }

  /// 建立勾選框
  Widget _buildCheckboxTile(BuildContext context, SensorAxis axis) {
    final isSelected = selectedAxes.contains(axis);

    return InkWell(
      onTap: () => onToggle(axis),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            // 勾選框
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => onToggle(axis),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),

            const SizedBox(width: 10),

            // 顏色指示器
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: axis.color,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Colors.grey.shade400),
              ),
            ),

            const SizedBox(width: 8),

            // 標籤
            Expanded(
              child: Text(
                axis.label,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 建立已選數量計數器
  Widget _buildSelectionCounter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timeline,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            '已選: ${selectedAxes.length} / ${SensorAxis.values.length}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
