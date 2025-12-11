# 快速設定指南

## ⚡ 5 分鐘快速啟動

### 步驟 1：安裝依賴

```bash
cd /Users/xuguanwen/Desktop/Projects/flutter/NTUT-UTL-Flutter-Monorepo_editV2
melos bootstrap
```

### 步驟 2：執行 App

```bash
cd apps/bracelet_app
flutter run
```

### 步驟 3：連接手環

1. 點擊右上角的 🔍 圖示
2. 選擇你的手環（通常名稱包含 "Nordic" 或韌體設定的名稱）
3. 等待連接（約 3-5 秒）
4. 看到綠色「已連接」狀態後，點擊「開始」按鈕

### 步驟 4：觀察波形

- 左側會顯示 12 條彩色波形線
- 右側控制面板顯示資料筆數
- 波形會即時更新（每秒 50 次）

### 步驟 5：匯出資料

1. 點擊「匯出 CSV」按鈕
2. 查看彈出視窗顯示的檔案路徑
3. 使用 Finder 或 ADB 取得檔案

---

## 🔧 進階設定

### 修改顯示範圍

編輯 `lib/presentation/screen/home_screen.dart`：

```dart
MlxChartView(
  dataList: notifier.dataList,
  title: 'MLX90393 即時波形',
  maxDataPoints: 100,  // 改這個數字（預設 100）
),
```

### 修改資料上限

編輯 `lib/presentation/change_notifier/bracelet_change_notifier.dart`：

```dart
static const int MAX_DATA_COUNT = 3000; // 改這個數字（預設 3000）
```

### 修改波形顏色

編輯 `lib/presentation/view/mlx_chart_view.dart`：

```dart
// MLX0 (藍色系)
_createLineSeries(data, 'MLX0-X', (d) => d.mlx0X.toDouble(), Colors.blue),
_createLineSeries(data, 'MLX0-Y', (d) => d.mlx0Y.toDouble(), Colors.blue[300]!),
_createLineSeries(data, 'MLX0-Z', (d) => d.mlx0Z.toDouble(), Colors.blue[100]!),
```

---

## ⚠️ 常見問題

### Q: 找不到手環裝置？

**A:**
1. 確認手環已開機
2. 確認藍牙已開啟
3. Android 需要定位權限
4. 點擊「重新掃描」

### Q: 連接後沒有資料？

**A:**
1. 檢查 Console 是否有「收到資料」的訊息
2. 確認封包標頭是否為 0x0A
3. 可能需要手動發送 'a' 指令（點擊「校正 IMU」旁邊的按鈕）

### Q: 波形數值異常（全是 0 或很大的數字）？

**A:**
1. 檢查封包的 Endianness（big/little endian）
2. 編輯 `bracelet_packet_parser.dart`，嘗試改成 `Endian.little`
3. 重新執行 App

### Q: CSV 檔案在哪裡？

**A:**
- **Android**: `/data/data/com.example.bracelet_app/files/MLX_*.csv`
- **iOS**: App 沙盒的 Documents 目錄
- 使用 `flutter run` 時，可以在 Console 看到完整路徑

---

## 📞 需要幫助？

如果遇到問題，請檢查：

1. **Console 日誌**：查看錯誤訊息
2. **藍牙權限**：確認 App 有藍牙和定位權限
3. **韌體版本**：確認手環韌體支援 NUS

---

**祝測試順利！** 🎉
