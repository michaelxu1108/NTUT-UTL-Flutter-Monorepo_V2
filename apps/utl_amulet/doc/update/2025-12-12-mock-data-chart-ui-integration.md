# 平安符 App - Mock 模式圖表 UI 整合

**日期**: 2025-12-12
**版本**: v1.1.0

## 📋 摘要

成功將左側圖表 UI (`AmuletLineChartList`) 整合至 Mock 模式的 HomeScreen，實現完整的假資料視覺化功能。

## ✨ 主要變更

### 1. HomeScreenMock 整合圖表 UI

**檔案**: `lib/presentation/screen/home_screen_mock.dart`

#### 變更內容：

1. **新增 import**：

   ```dart
   import 'package:utl_amulet/presentation/view/amulet/amulet_line_chart_list.dart';
   ```

2. **啟用圖表組件**：

   ```dart
   // 從註解改為啟用
   const amuletLineChartList = AmuletLineChartList();
   ```

3. **替換左側佔位符為實際圖表**：

   ```dart
   // 之前：紫色佔位符
   Expanded(
     child: Container(
       color: Colors.purple.shade50,
       child: const Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(Icons.show_chart, size: 80, color: Colors.purple),
             Text('Chart Area'),
             Text('(AmuletLineChartList temporarily disabled)'),
           ],
         ),
       ),
     ),
   ),

   // 之後：實際圖表組件
   const Expanded(
     child: amuletLineChartList,
   ),
   ```

## 🎯 功能說明

### Mock 模式完整功能

1. **左側區域**：

   - 顯示 `AmuletLineChartList` 圖表列表
   - 實時更新來自 `MockBluetoothModule` 的假資料
   - 包含以下圖表：
     - 加速度 (AccX, AccY, AccZ, AccTotal)
     - 姿態角 (Roll, Pitch, Yaw)
     - 磁力計 (MagX, MagY, MagZ, MagTotal)
     - 氣壓 (Pressure)
     - 姿勢狀態 (Posture)
     - 信標 RSSI (BeaconRssi)
     - 點位 (Point)

2. **右側區域**：

   - 三個 Tab 頁面：
     - 🔵 **Bluetooth Scanner**: 顯示 Mock 裝置 "Htag (Mock)"
     - 📊 **Data List**: 即時感測器數據列表
     - ⚙️ **Control Panel**: 控制面板

### 數據流程

```
MockBluetoothModule (50 Hz)
    ↓
BluetoothReceivedPacket
    ↓
AmuletSensorDataStream
    ↓
AmuletLineChartManagerChangeNotifier
    ↓
AmuletLineChartList (圖表顯示)
```

## 🔧 技術細節

### 數據生成頻率

- **頻率**: 50 Hz (每 20 毫秒一次)
- **數據包大小**: 42 bytes
- **格式**: 符合實際藍牙封包協議

### 圖表特性

- 使用 `Consumer<AmuletLineChartManagerChangeNotifier>` 監聽數據變化
- 自動分頁顯示多個圖表
- 每個圖表高度為可用高度的 1/2.5
- 支援實時數據更新

## 📱 使用方式

### 啟用 Mock 模式

在 `lib/main.dart` 中設定：

```dart
const bool useMockData = true;  // 啟用假資料模式
```

### 運行應用

```bash
flutter run
```

### 預期行為

1. App 啟動後自動進入橫向模式
2. 左側顯示實時更新的圖表
3. 右側顯示控制面板和數據列表
4. 無需實際藍牙裝置即可測試完整功能

## ✅ 測試結果

### 成功驗證項目

- [x] Mock 模式啟動成功
- [x] 圖表正常顯示
- [x] 數據實時更新 (50 Hz)
- [x] UI 無崩潰或錯誤
- [x] 三個 Tab 頁面都可正常切換
- [x] Data tab 顯示即時感測器數據
- [x] 佈局適應橫向螢幕

### 日誌確認

```
I/flutter: 🎭 應用啟動 - Mock 資料模式
I/flutter: 📱 Mock 設備: Htag (Mock)
I/flutter: 🔢 Mock ID: MOCK:00:00:00:00:00
I/flutter: 🏠 HomeScreenMock.build() 開始
I/flutter: 🏠 開始返回最終 Scaffold
I/flutter: 🟢 開始生成假數據 (50 Hz)
I/flutter: 🟢 開始生成 Mock 資料
```

## 🎨 UI 佈局

```
┌─────────────────────────────────────────────────┐
│                                    │  BT Scan  │
│                                    ├───────────┤
│                                    │           │
│      AmuletLineChartList          │   Data    │
│      (實時圖表更新)                  │   List    │
│                                    │           │
│                                    ├───────────┤
│                                    │  Control  │
│                                    │   Panel   │
└─────────────────────────────────────────────────┘
        左側 (2/3 寬度)                  右側 (1/3 寬度)
```

## 📊 Mock 數據特性

### 加速度數據

- **AccX**: sin(t _ 0.5) _ 500 + 隨機噪音 (±50)
- **AccY**: cos(t _ 0.7) _ 300 + 隨機噪音 (±50)
- **AccZ**: sin(t _ 0.3) _ 200 + 16384 + 隨機噪音 (±50)

### 姿態角數據

- **Roll**: sin(t _ 0.4) _ 30° + 隨機噪音 (±5°)
- **Pitch**: cos(t _ 0.6) _ 20° + 隨機噪音 (±5°)
- **Yaw**: 循環 0-360° (每秒增加 10°)

### 其他數據

- **Temperature**: 25.00-28.00°C 波動
- **Battery**: 75-85% 隨機
- **Posture**: 隨機姿勢狀態
- **Pressure**: 1013.25 ± 2.0 hPa

## 🔄 相關檔案

### 修改檔案

- `lib/presentation/screen/home_screen_mock.dart`

### 相關檔案

- `lib/infrastructure/source/bluetooth/mock_bluetooth_module.dart` - Mock 數據生成
- `lib/presentation/view/amulet/amulet_line_chart_list.dart` - 圖表列表組件
- `lib/presentation/view/amulet/amulet_dashboard_mock.dart` - 數據列表 Mock 版本
- `lib/main.dart` - Mock 模式開關

## 🚀 下一步

Mock 模式已完全實現，包含：

1. ✅ 假資料生成 (50 Hz)
2. ✅ 圖表視覺化
3. ✅ 數據列表顯示
4. ✅ 藍牙掃描模擬

可以開始進行：

- 實際藍牙裝置整合測試
- UI/UX 優化
- 新功能開發

---

**備註**: 此更新完成了 Mock 模式的最後一塊拼圖，現在開發者可以在無需實際硬體的情況下，完整測試平安符 App 的所有功能。
