# UTL Amulet - Mock 資料模式使用說明

## 快速開始

### 啟用 Mock 模式（假資料）

1. 打開 `lib/main.dart`
2. 修改第 24 行：
```dart
const bool useMockData = true;  // ← 改為 true
```
3. 執行應用：
```bash
flutter run
```

### 關閉 Mock 模式（使用真實藍牙）

1. 打開 `lib/main.dart`
2. 修改第 24 行：
```dart
const bool useMockData = false;  // ← 改為 false
```
3. 執行應用：
```bash
flutter run
```

## Mock 模式特點

- ✅ **無需藍牙設備** - 完全不依賴硬體
- ✅ **自動生成數據** - 每 20ms 生成一次假資料 (50 Hz)
- ✅ **真實模擬** - 使用正弦波 + 隨機噪音模擬真實運動
- ✅ **自動連接** - 啟動後自動連接到 Mock 設備
- ✅ **完整數據** - 包含所有感測器數值（加速度、磁力計、姿態等）

## Mock 設備資訊

- **設備名稱:** `Htag (Mock)`
- **設備 ID:** `MOCK:00:00:00:00:00`
- **更新頻率:** 50 Hz (每 20ms)

## 注意事項

⚠️ Mock 模式僅供開發和測試使用，發布版本請確保設定為 `false`

## 詳細文檔

完整的實作說明請參考：
- `doc/update/2025-12-12-mock-data-mode-implementation.md`
