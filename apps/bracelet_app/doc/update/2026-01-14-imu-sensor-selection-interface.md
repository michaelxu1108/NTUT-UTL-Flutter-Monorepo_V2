# IMU 感測器選擇介面實現

**日期**: 2026-01-14
**版本**: v1.0.0
**開發者**: Claude Sonnet 4.5

## 📋 目錄

- [需求背景](#需求背景)
- [功能概述](#功能概述)
- [技術實現](#技術實現)
- [UI 設計](#ui-設計)
- [問題與解決](#問題與解決)
- [使用方式](#使用方式)
- [未來優化](#未來優化)

---

## 需求背景

### 使用情境

手環硬體配置：
- **4個 MLX90393 磁力感測器**：分別對應拇指、食指、中指、無名指
- **1個 ICM-20948 IMU**：包含加速度計、陀螺儀、磁力計

### 核心需求

用戶需要同時觀察 IMU 和 MLX 的數據，因為：
1. **IMU 用於偵測手部動作**
2. **手部移動時，MLX 讀數會不準確**
3. **需要比對 IMU 與 MLX 數據來判斷資料可靠性**

用戶希望能夠：
- 選擇任意感測器軸向進行比較（包含 X/Y/Z 各軸）
- 在同一張圖表上顯示多條波形
- 快速切換不同的感測器組合

---

## 功能概述

### 核心功能

1. **21 個感測器軸向可選**
   - MLX90393: 12 軸（4 個感測器 × 3 軸）
   - 加速度計: 3 軸
   - 陀螺儀: 3 軸
   - 磁力計: 3 軸

2. **多選勾選框介面**
   - 依分類組織（MLX、Accelerometer、Gyroscope、Magnetometer）
   - 顏色標示器（每個軸向有獨特顏色）
   - 全選/清空快速操作

3. **動態圖表顯示**
   - 根據選擇動態生成波形
   - 每條波形使用對應軸向的顏色
   - 圖例顯示當前選擇的軸向

4. **響應式佈局**
   - 橫版：三欄佈局（選擇器 + 圖表 + 控制面板）
   - 直立：上中下佈局（選擇器 + 圖表 + 控制面板）

---

## 技術實現

### 新增檔案

#### 1. `lib/domain/entity/sensor_axis.dart`

定義感測器軸向的核心枚舉：

```dart
enum SensorAxis {
  // MLX90393 (12 軸)
  mlx0X, mlx0Y, mlx0Z,  // 拇指
  mlx1X, mlx1Y, mlx1Z,  // 食指
  mlx2X, mlx2Y, mlx2Z,  // 中指
  mlx3X, mlx3Y, mlx3Z,  // 無名指

  // IMU 加速度計 (3 軸)
  accX, accY, accZ,

  // IMU 陀螺儀 (3 軸)
  gyroX, gyroY, gyroZ,

  // IMU 磁力計 (3 軸)
  magX, magY, magZ;

  // 每個軸向包含：
  // - label: 顯示標籤
  // - description: 詳細描述
  // - color: 唯一顏色
  // - getValue(): 從資料中提取數值
}

enum SensorCategory {
  mlx,           // MLX90393 磁力計
  accelerometer, // IMU - 加速度計
  gyroscope,     // IMU - 陀螺儀
  magnetometer;  // IMU - 磁力計

  // 提供分類的標題、圖標、包含的軸向
}
```

**設計特點**：
- 每個軸向有獨特的顏色（21種不同顏色）
- 提供 `getValue(MlxSensorData)` 方法統一資料提取介面
- 自動分類管理（透過 `category` getter）

#### 2. `lib/presentation/view/sensor_selection_view.dart`

多選勾選框側邊欄元件：

```dart
class SensorSelectionView extends StatelessWidget {
  final Set<SensorAxis> selectedAxes;
  final ValueChanged<SensorAxis> onToggle;
  final VoidCallback onSelectAll;
  final VoidCallback onClearAll;
  final bool showHeader;  // 控制是否顯示標題（適應不同佈局）

  // 功能：
  // - 按分類顯示所有感測器
  // - 勾選框 + 顏色指示器 + 標籤
  // - 全選/清空按鈕（可選）
  // - 已選數量顯示（可選）
}
```

**UI 組成**：
- 標題列（可選）：「選擇感測器」+ 全選/清空按鈕
- 分類區塊：依 SensorCategory 分組顯示
- 勾選項目：勾選框 + 顏色方塊（16×16） + 軸向標籤
- 計數器（可選）：顯示「已選: X / 21」

#### 3. `lib/presentation/view/dynamic_chart_view.dart`

動態波形圖表元件：

```dart
class DynamicChartView extends StatelessWidget {
  final List<MlxSensorData> dataList;
  final Set<SensorAxis> selectedAxes;
  final int maxDataPoints;

  // 功能：
  // - 根據 selectedAxes 動態生成 LineSeries
  // - 自動限制顯示的資料點數量
  // - 空狀態提示（未選擇感測器時）
  // - 圖例顯示當前選擇
}
```

**圖表特性**：
- 使用 Syncfusion Charts 渲染
- 每條波形使用對應軸向的顏色
- X 軸：資料序號（0, 1, 2...）
- Y 軸：感測器數值（自動縮放）
- 圖例位置：底部水平排列

### 修改檔案

#### `lib/presentation/screen/home_screen.dart`

整合新 UI 元件：

**新增狀態管理**：
```dart
class _HomeScreenState extends State<HomeScreen> {
  Set<SensorAxis> _selectedAxes = {};

  @override
  void initState() {
    super.initState();
    // 預設選擇 5 個感測器
    _selectedAxes = {
      SensorAxis.mlx0Z,
      SensorAxis.mlx1Z,
      SensorAxis.accX,
      SensorAxis.accY,
      SensorAxis.accZ,
    };
  }

  void _toggleAxis(SensorAxis axis) { /* 切換選擇 */ }
  void _selectAll() { /* 全選 */ }
  void _clearAll() { /* 清空 */ }
}
```

**橫版佈局（Landscape）**：
```
┌────────────┬──────────────────┬────────────┐
│            │                  │            │
│  Sensor    │   Dynamic Chart  │  Control   │
│  Selection │                  │  Panel     │
│  (200-240) │   (自動填滿)      │  (240-280) │
│            │                  │            │
└────────────┴──────────────────┴────────────┘
```

**直立佈局（Portrait）**：
```
┌──────────────────────────────┐
│  選擇感測器 [5] 全選 清空      │
│ ┌──────────────────────────┐ │
│ │ ☑ MLX0-X  ☑ MLX0-Y ...   │ │  ← 固定 180px
│ └──────────────────────────┘ │
├──────────────────────────────┤
│                              │
│      Dynamic Chart           │  ← flex: 5
│                              │
├──────────────────────────────┤
│                              │
│      Control Panel           │  ← 固定 140px
│                              │
└──────────────────────────────┘
```

---

## UI 設計

### 顏色方案

每個感測器軸向都配置了獨特的顏色，便於在圖表中識別：

**MLX90393（藍色系）**：
- MLX0（拇指）: 藍色 `#2196F3`, 淺藍 `#03A9F4`, 深藍 `#0D47A1`
- MLX1（食指）: 綠色 `#4CAF50`, 淺綠 `#66BB6A`, 深綠 `#2E7D32`
- MLX2（中指）: 黃色 `#FFEB3B`, 金色 `#FFD54F`, 橙黃 `#F57F17`
- MLX3（無名指）: 紅色 `#F44336`, 淺紅 `#EF5350`, 深紅 `#C62828`

**IMU（其他色系）**：
- 加速度計: 紫色系 `#9C27B0`, `#BA68C8`, `#6A1B9A`
- 陀螺儀: 青色系 `#00BCD4`, `#4DD0E1`, `#006064`
- 磁力計: 深橙系 `#FF5722`, `#FF8A65`, `#BF360C`

### 響應式設計

**螢幕寬度判斷**：
```dart
final isLandscape = constraints.maxWidth > constraints.maxHeight;
```

**動態尺寸調整**：
- 橫版選擇器寬度：寬螢幕 240px，窄螢幕 200px
- 橫版控制面板寬度：寬螢幕 280px，窄螢幕 240px
- 直立模式固定高度：選擇器 180px，控制面板 140px

---

## 問題與解決

### 問題 1: Android 直立模式看不到感測器選擇

**現象**：
- macOS 橫版正常顯示
- Android 直立模式無法看到感測器選擇

**原因分析**：
1. Android 裝置預設以直立模式啟動
2. 直立佈局使用 `ExpansionTile` 折疊式設計
3. `ExpansionTile` 預設 `initiallyExpanded: false`（收合）
4. 用戶未意識到需要點擊展開

**嘗試方案 1**：設定 `initiallyExpanded: true`
- 結果：展開後占用過多空間（200px + 標題），影響圖表和控制面板顯示

**嘗試方案 2**：減少高度並調整 flex 比例
- 感測器選擇高度：200px → 160px
- 圖表與控制面板比例：4:1 → 3:2
- 結果：仍然預設收合，用戶不知道要展開

**最終方案**：移除 `ExpansionTile`，使用固定高度容器
```dart
// 改為固定高度的 Container + 自定義標題列
Container(
  height: 180,
  child: Column(
    children: [
      // 自定義標題列（標題 + 數量 + 全選/清空按鈕）
      Container(/* 標題列 */),
      // 感測器選擇列表（showHeader: false 避免重複）
      Expanded(
        child: SensorSelectionView(showHeader: false),
      ),
    ],
  ),
)
```

**優點**：
- ✅ 感測器選擇始終可見
- ✅ 固定高度，不會壓縮其他元件
- ✅ 圖表有充足空間（flex: 5）
- ✅ 控制面板固定 140px，可捲動查看所有按鈕

### 問題 2: SensorSelectionView 重複顯示標題

**現象**：
在直立佈局中，外層已有標題列，但 `SensorSelectionView` 內部也顯示標題和按鈕，造成重複。

**解決方案**：
新增 `showHeader` 參數：
```dart
class SensorSelectionView extends StatelessWidget {
  final bool showHeader;  // 預設 true（橫版用）

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showHeader) ...[
          _buildHeader(context),
          Divider(),
        ],
        Expanded(child: ListView(/* 選項列表 */)),
        if (showHeader) _buildSelectionCounter(context),
      ],
    );
  }
}
```

**使用方式**：
- 橫版（側邊欄）：`showHeader: true`（預設）
- 直立（嵌入容器）：`showHeader: false`

---

## 使用方式

### 基本操作

1. **選擇感測器**：
   - 點擊任意勾選框來選擇/取消選擇
   - 點擊「全選」按鈕選擇所有 21 個軸向
   - 點擊「清空」按鈕取消所有選擇

2. **查看波形**：
   - 選擇的感測器會即時顯示在圖表上
   - 每條波形使用對應的顏色
   - 圖例顯示在圖表底部

3. **分類瀏覽**：
   - MLX90393 磁力計：12 個軸向
   - IMU - 加速度計：3 個軸向
   - IMU - 陀螺儀：3 個軸向
   - IMU - 磁力計：3 個軸向

### 預設選擇

應用啟動時預設選擇 5 個感測器：
- `MLX0-Z`（拇指 Z 軸）
- `MLX1-Z`（食指 Z 軸）
- `IMU-AccX`（加速度 X 軸）
- `IMU-AccY`（加速度 Y 軸）
- `IMU-AccZ`（加速度 Z 軸）

### 切換方向

- **橫版**：感測器選擇顯示在左側邊欄
- **直立**：感測器選擇顯示在頂部固定區域

---

## 未來優化

### 建議改進項目

1. **感測器組合預設集**
   - 新增「常用組合」功能
   - 例如：「僅 MLX」、「僅 IMU」、「手部動作偵測組合」等

2. **圖表縮放與平移**
   - 支援雙指縮放
   - 平移查看歷史資料
   - 時間軸標記

3. **資料匯出**
   - 匯出選定軸向的 CSV
   - 包含時間戳記

4. **效能優化**
   - 大量感測器同時顯示時的渲染優化
   - 考慮使用虛擬化列表（當感測器數量更多時）

5. **自訂顏色**
   - 允許使用者自訂每個軸向的顏色
   - 儲存自訂設定

6. **即時統計**
   - 顯示選定感測器的最大值、最小值、平均值
   - 異常值標示

---

## 相關檔案

### 新增檔案
- `lib/domain/entity/sensor_axis.dart`
- `lib/presentation/view/sensor_selection_view.dart`
- `lib/presentation/view/dynamic_chart_view.dart`

### 修改檔案
- `lib/presentation/screen/home_screen.dart`
  - 新增狀態管理 `_selectedAxes`
  - 新增操作方法 `_toggleAxis`, `_selectAll`, `_clearAll`
  - 重構橫版佈局（三欄）
  - 重構直立佈局（固定高度容器）

### 移除的程式碼
- `import '../view/mlx_chart_view.dart'`（已棄用）
- `_buildDataCards()`（已棄用）
- `_buildMiniDataCard()`（已棄用）
- `_buildDataCard()`（已棄用）
- 調試 print 語句（已移除）

---

## 測試結果

### 測試環境

- **macOS**：Darwin 25.2.0
- **Android Emulator**：sdk gphone64 arm64 (API 31)
- **Flutter SDK**：最新穩定版

### 測試項目

✅ 橫版佈局顯示正常
✅ 直立佈局顯示正常
✅ 21 個感測器軸向都可正常選擇
✅ 圖表動態生成正確
✅ 顏色對應正確
✅ 全選/清空功能正常
✅ Mock 模式資料正常顯示
✅ 響應式切換正常

---

## 總結

本次更新成功實現了多感測器軸向選擇與動態圖表顯示功能，解決了 IMU 與 MLX 資料同步比對的需求。透過精心設計的 UI 佈局和響應式設計，確保在橫版和直立模式下都能提供良好的使用體驗。

**核心成果**：
- ✅ 21 個感測器軸向可獨立選擇
- ✅ 動態多波形圖表
- ✅ 響應式佈局適配
- ✅ 直觀的顏色識別系統
- ✅ Android 與 macOS 平台相容

**使用者價值**：
- 可自由組合觀察不同感測器
- 即時比對 IMU 與 MLX 資料
- 判斷手部動作對磁力感測的影響
- 提升資料分析效率
