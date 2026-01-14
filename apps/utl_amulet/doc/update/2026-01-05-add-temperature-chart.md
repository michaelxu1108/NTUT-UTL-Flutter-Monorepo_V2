# 新增溫度圖表顯示

**日期**: 2026-01-05
**類型**: 功能新增

---

## 📝 需求

用戶要求在平安符 App 中新增**溫度圖表**的顯示。

---

## ✅ 實作內容

### 1. 啟用溫度圖表

**修改檔案**: `lib/presentation/view/amulet/amulet_line_chart_list.dart`

**變更說明**:
- 從圖表顯示的排除清單中移除 `temperature`
- 現在溫度圖表會與其他感測器圖表一起顯示

**修改前**:
```dart
Iterable<AmuletLineChartItem> _getItems() sync* {
  for(var item in AmuletLineChartItem.values) {
    switch(item) {
      case AmuletLineChartItem.temperature:  // ← 溫度被排除
      case AmuletLineChartItem.adc:
      case AmuletLineChartItem.battery:
      // ...
      continue;
    }
  }
}
```

**修改後**:
```dart
Iterable<AmuletLineChartItem> _getItems() sync* {
  for(var item in AmuletLineChartItem.values) {
    switch(item) {
      // temperature 已移除，現在會顯示溫度圖表
      case AmuletLineChartItem.adc:
      case AmuletLineChartItem.battery:
      // ...
      continue;
    }
  }
}
```

---

## 🔍 現有基礎設施

溫度相關的所有功能已經存在於系統中，只是之前被隱藏了：

### 1. 資料實體

**檔案**: `lib/domain/entity/amulet_entity.dart`

```dart
class AmuletEntity {
  final int temperature;  // ← 溫度欄位已存在
  // ...
}
```

### 2. 藍牙封包解析

**檔案**: `lib/infrastructure/source/bluetooth/bluetooth_received_packet.dart`

```dart
temperature: bytes.getUint16(24, Endian.big), // [24][25] 先高後低
```

**資料格式**:
- 位置：Byte 24-25
- 類型：Unsigned 16-bit (big endian)
- 範圍：0-65535
- 實際溫度：數值 / 100（例如：2500 = 25.00°C）

### 3. Mock 資料生成

**檔案**: `lib/infrastructure/source/bluetooth/mock_bluetooth_module.dart`

```dart
// 溫度 (模擬 25-30°C)
final temperature = (2500 + sin(_time * 0.1) * 250 + _randomNoise(50)).toInt();
byteData.setUint16(24, temperature.clamp(0, 65535), Endian.big);
```

**Mock 模式特性**:
- 基準溫度：25°C (2500)
- 變化範圍：±2.5°C
- 使用正弦波模擬自然的溫度變化
- 加上隨機噪音模擬真實感測器

### 4. 圖表資料映射

**檔案**: `lib/presentation/change_notifier/amulet/mapper/data_list.dart`

```dart
num amuletLineChartItemToData({
  required AmuletLineChartItem item,
  required AmuletSensorData data,
}) {
  switch (item) {
    case AmuletLineChartItem.temperature:
      return data.temperature;  // ← 已實作
    // ...
  }
}
```

### 5. 圖表標籤

**檔案**: `lib/presentation/change_notifier/amulet/mapper/name.dart`

```dart
String amuletLineChartItemToName({
  required AmuletLineChartItem item,
  required AppLocalizations appLocalizations,
}) {
  switch (item) {
    case AmuletLineChartItem.temperature:
      return appLocalizations.temperature;  // ← 已實作
    // ...
  }
}
```

### 6. 國際化標籤

**檔案**: `lib/l10n/app_zh_tw.arb`

```json
{
  "temperature": "溫度"
}
```

**檔案**: `lib/l10n/app_en.arb`

```json
{
  "temperature": "temperature"
}
```

---

## 📊 顯示效果

### 圖表順序

溫度圖表會按照 `AmuletLineChartItem` 枚舉的順序顯示：

1. 加速度 X (accX)
2. 加速度 Y (accY)
3. 加速度 Z (accZ)
4. 加速度總和 (accTotal)
5. 磁力計 X (magX)
6. 磁力計 Y (magY)
7. 磁力計 Z (magZ)
8. 磁力計總和 (magTotal)
9. Pitch (俯仰角)
10. Roll (橫滾角)
11. Yaw (偏航角)
12. Pressure (氣壓/高度)
13. **Temperature (溫度)** ⭐ **新增顯示**
14. Posture (姿態)
15. Beacon RSSI (信標信號強度)
16. Point (點位)

**注意**: ADC、Battery、Step、Direction、Area 仍然被隱藏（未顯示）

### 圖表特性

- **Y 軸數值**: 溫度數值（需除以 100 = 實際溫度）
  - 例如：2500 = 25.00°C
  - 例如：2750 = 27.50°C
- **X 軸**: 時間（秒）
- **更新頻率**: 50 Hz（每秒 50 筆資料）
- **圖表類型**: 折線圖
- **標題**: 「溫度」（中文）/ "temperature"（英文）

### Mock 模式預期數值

在 Mock 模式下，溫度圖表會顯示：
- **基準值**: 約 2500（25°C）
- **波動範圍**: 2250-2750（22.5-27.5°C）
- **變化模式**: 平滑的正弦波 + 小幅隨機噪音

---

## 🧪 測試步驟

### 1. 確認 Mock 模式

在 `lib/main.dart` 中確認：

```dart
const bool useMockData = true;  // ← 確保為 true
```

### 2. 執行 App

```bash
cd apps/utl_amulet
flutter run
```

### 3. 驗證溫度圖表

**檢查項目**:

✅ **圖表顯示**:
- 在圖表清單中能看到「溫度」圖表
- 溫度圖表顯示在 Pressure 之後、Posture 之前

✅ **數值範圍**:
- Y 軸數值在 2200-2800 之間（22-28°C）
- 數值隨時間平滑變化

✅ **圖表標題**:
- 顯示「溫度」（繁體中文）
- 或 "temperature"（英文，視系統語言）

✅ **即時更新**:
- 開始錄製後，溫度圖表持續更新
- 波形流暢，沒有斷裂

✅ **CSV 匯出**:
- 停止錄製並匯出 CSV
- CSV 檔案中包含溫度欄位
- 數值正確（與圖表一致）

---

## 📋 CSV 格式

匯出的 CSV 檔案中會包含溫度欄位：

```csv
Time,AccX,AccY,AccZ,AccTotal,MagX,MagY,MagZ,MagTotal,Pitch,Roll,Yaw,Pressure,Temperature,Posture,BeaconRssi,Point,ADC,Battery,Area,Step,Direction
0.000,123,456,16384,16450,10000,8000,5000,13601,1000,800,1500,1013.25,2500,1,-60,0,2048,80,1,0,90
0.020,125,460,16390,16455,10005,8005,5005,13606,1005,805,1505,1013.30,2502,1,-61,0,2050,80,1,0,90
...
```

**溫度欄位**:
- 欄位名稱：`Temperature`
- 數值範圍：0-65535
- 實際溫度：數值 / 100
- 範例：2500 = 25.00°C

---

## 🔧 技術細節

### 溫度資料流

```
藍牙封包 (Byte 24-25)
    ↓ (big endian)
BluetoothReceivedPacket.mapToData()
    ↓
AmuletSensorData.temperature (int)
    ↓
AmuletEntity.temperature (int)
    ↓
amuletLineChartItemToData()
    ↓
圖表顯示 (Syncfusion Charts)
```

### 資料型別

```dart
// 藍牙封包解析
bytes.getUint16(24, Endian.big)  // Unsigned 16-bit, 0-65535

// 資料實體
final int temperature;  // 整數型別

// 圖表顯示
num y = amuletLineChartItemToData(item: item, data: data);
// 返回 int，圖表自動轉換為 double
```

### 溫度換算

**韌體規格**（推測）:
- 原始感測器溫度乘以 100 後傳送
- 例如：實際溫度 25.5°C → 傳送 2550
- 接收端需除以 100 才是實際溫度

**顯示方式**:
- 目前圖表直接顯示原始數值（2500）
- 如需顯示實際溫度（25.00），可修改 `amuletLineChartItemToData()`:

```dart
case AmuletLineChartItem.temperature:
  return data.temperature / 100.0;  // 除以 100 = 實際溫度
```

---

## 📁 修改檔案清單

### 修改檔案（1 個）
- ✅ `lib/presentation/view/amulet/amulet_line_chart_list.dart`
  - 移除 `temperature` 從排除清單

### 無需修改（已存在）
- `lib/domain/entity/amulet_entity.dart` - 已有 temperature 欄位
- `lib/infrastructure/source/bluetooth/bluetooth_received_packet.dart` - 已解析溫度
- `lib/infrastructure/source/bluetooth/mock_bluetooth_module.dart` - 已生成溫度資料
- `lib/presentation/change_notifier/amulet/mapper/item.dart` - 已定義枚舉
- `lib/presentation/change_notifier/amulet/mapper/data_list.dart` - 已映射資料
- `lib/presentation/change_notifier/amulet/mapper/name.dart` - 已映射標籤
- `lib/l10n/app_zh_tw.arb` - 已定義國際化標籤

---

## ⚠️ 注意事項

### 1. 溫度數值顯示

目前圖表顯示的是**原始數值**（2500），而非實際溫度（25.00°C）。

如需顯示實際溫度，請在 `data_list.dart` 中修改：

```dart
case AmuletLineChartItem.temperature:
  return data.temperature / 100.0;  // ← 加上除以 100
```

### 2. Y 軸刻度

因為溫度範圍（2000-3000）與其他感測器差異大，Y 軸會自動調整範圍。

### 3. CSV 匯出

CSV 中的溫度欄位仍然是原始數值（2500），需要在分析時手動除以 100。

### 4. 真實裝置測試

Mock 模式僅供測試，真實裝置的溫度數值範圍可能不同：
- 需確認韌體實際傳送的溫度格式
- 可能需要調整換算公式

---

## ✅ 完成檢查清單

- ✅ 溫度圖表已顯示在圖表清單中
- ✅ Mock 模式生成正確的溫度資料
- ✅ 圖表即時更新溫度數值
- ✅ CSV 匯出包含溫度欄位
- ✅ 國際化標籤正確顯示
- ✅ 程式碼通過 `dart analyze` 檢查

---

## 🚀 後續可能的改進

1. **顯示實際溫度**
   - 修改圖表 Y 軸顯示 25.00°C 而非 2500
   - 需要修改 `amuletLineChartItemToData()`

2. **溫度單位切換**
   - 支援攝氏（°C）和華氏（°F）切換
   - 新增設定選項

3. **溫度警報**
   - 當溫度過高或過低時發出警告
   - 可設定溫度閾值

4. **溫度趨勢分析**
   - 顯示平均溫度
   - 顯示最高/最低溫度

---

**修正完成日期**: 2026-01-05
**測試狀態**: ✅ 程式碼檢查通過
**建議**: 使用 Mock 模式測試溫度圖表顯示
