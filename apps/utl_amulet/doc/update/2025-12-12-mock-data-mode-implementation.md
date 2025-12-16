# Mock Data Mode Implementation

**Date:** 2025-12-12
**Author:** MichaelXu

---

## 概述

為了解決平安符專案在沒有真實藍牙設備時「卡在藍牙頁面」的問題，實作了假資料模式（Mock Data Mode）。此模式允許開發者和測試人員在沒有實體設備的情況下測試應用程式的所有功能。

---

## 實作內容

### 1. MockBluetoothModule 類別

**檔案位置:** `lib/infrastructure/source/bluetooth/mock_bluetooth_module.dart`

**功能特點:**

- ✅ 每 20ms (50 Hz) 自動生成假資料
- ✅ 使用正弦波 + 隨機噪音模擬真實感測器數據
- ✅ 生成完整的 42 bytes 藍牙封包
- ✅ 模擬所有感測器數值（加速度、磁力計、姿態、溫度等）
- ✅ Mock 設備資訊：
  - 設備 ID: `MOCK:00:00:00:00:00`
  - 設備名稱: `Htag (Mock)`

**主要方法:**

```dart
void startGeneratingData()  // 開始生成假資料
void stopGeneratingData()   // 停止生成假資料
Stream<BluetoothReceivedPacket> get onReceivePacket  // 封包串流
Future<bool> sendCommand({required String command})  // 模擬發送指令
void cancel()  // 清理資源
```

**模擬的數據類型:**

- 加速度計 (accX, accY, accZ, accTotal)
- 歐拉角 (roll, pitch, yaw)
- 磁力計 (magX, magY, magZ, magTotal)
- 溫度 (25-30°C 範圍)
- 姿態 (每 5 秒切換一次)
- Beacon RSSI (-40 ~ -80 dBm)
- 方向 (0-360 度旋轉)
- ADC、電池、區域、步數、點位
- 氣壓/高度 (Float32)

---

### 2. Main.dart 整合 Mock 模式開關

**檔案位置:** `lib/main.dart`

**功能:**

- ✅ 使用 `const bool useMockData` 控制 Mock 模式
- ✅ 根據開關自動創建 MockBluetoothModule 或使用真實藍牙模組
- ✅ 自動啟動假資料生成（Mock 模式下）
- ✅ 根據模式選擇 HomeScreenMock 或 HomeScreen
- ✅ 提供 MockBluetoothModule 至 Provider（Mock 模式下）

**使用方式:**

```dart
// 在 lib/main.dart 第 24 行
const bool useMockData = true;  // 啟用 Mock 模式
// 或
const bool useMockData = false; // 正常模式
```

然後執行：

```bash
flutter run
```

---

### 3. Mock 專用 UI 組件

#### HomeScreenMock

**檔案位置:** `lib/presentation/screen/home_screen_mock.dart`

**特點:**

- ✅ 跳過藍牙適配器狀態檢查
- ✅ 不依賴 flutter_blue_plus 的藍牙狀態
- ✅ 直接顯示主介面，不會卡在藍牙頁面
- ✅ 使用 Mock 版本的藍牙掃描器

#### BluetoothScannerViewMock

**檔案位置:** `lib/presentation/view/bluetooth/bluetooth_scanner_view_mock.dart`

**特點:**

- ✅ 顯示 Mock 設備卡片，帶有明顯的 "MOCK" 標識
- ✅ 預設已自動連接到 Mock 設備
- ✅ 支援手動斷開/重新連接
- ✅ 顯示詳細的 Mock 模式說明資訊
- ✅ 美觀的 UI 設計，清楚標示為測試模式

---

### 4. 架構修改

#### Initializer 修改

**檔案位置:** `lib/init/initializer.dart`

**變更內容:**

```dart
// 修改前
BluetoothResource.bluetoothModule = BluetoothModule();

// 修改後 - 支援依賴注入
class Initializer {
  final dynamic bluetoothModule;

  Initializer({this.bluetoothModule});

  Future call() async {
    BluetoothResource.bluetoothModule = bluetoothModule ?? BluetoothModule();
    // ...
  }
}
```

#### BluetoothResource 修改

**檔案位置:** `lib/init/resource/infrastructure/bluetooth_resource.dart`

**變更內容:**

```dart
// 修改前
static BluetoothModule? _bluetoothModule;
static BluetoothModule get bluetoothModule { ... }
static set bluetoothModule(BluetoothModule value) { ... }

// 修改後 - 接受任意類型
static dynamic _bluetoothModule;
static dynamic get bluetoothModule { ... }
static set bluetoothModule(dynamic value) { ... }
```

---

## 使用指南

### 啟動 Mock 模式

**步驟 1:** 修改 `lib/main.dart` 第 24 行

```dart
const bool useMockData = true;  // 改為 true
```

**步驟 2:** 執行應用

```bash
cd apps/utl_amulet
flutter run
```

### 切換回正常模式 (需要真實藍牙設備)

**步驟 1:** 修改 `lib/main.dart` 第 24 行

```dart
const bool useMockData = false;  // 改為 false
```

**步驟 2:** 執行應用

```bash
flutter run
```

**提示:** 使用 Hot Restart (Shift + R) 可以快速重新啟動應用來切換模式

---

## Mock 資料生成細節

### 加速度資料

```dart
accX: sin(time * 0.5) * 500 ± 50 (噪音)
accY: cos(time * 0.7) * 300 ± 50
accZ: sin(time * 0.3) * 200 + 16384 ± 50  // 接近 1g 重力
```

### 歐拉角

```dart
roll:  sin(time * 0.4) * 1000 ± 20
pitch: cos(time * 0.6) * 800 ± 20
yaw:   sin(time * 0.3) * 1500 ± 30
```

### 磁力計

```dart
magX: sin(time * 0.2) * 2000 + 10000 ± 100  // 8000~12000
magY: cos(time * 0.25) * 1500 + 8000 ± 100  // 6500~9500
magZ: sin(time * 0.15) * 1000 + 5000 ± 100  // 4000~6000
```

### 姿態切換

每 5 秒自動切換姿態類型（Init, Sit, Stand 等）

---

## 優點

1. **無需硬體設備** - 可在任何環境下開發和測試
2. **穩定的測試資料** - 每次執行都產生可預測的模擬數據
3. **快速迭代** - 不需等待藍牙連接，立即看到 UI 效果
4. **完整功能測試** - 所有數據欄位都有模擬值
5. **真實的數據模式** - 使用正弦波模擬自然運動

---

## 注意事項

⚠️ **Mock 模式僅供開發和測試使用**

- Mock 資料不代表真實的感測器讀數
- 正式發布版本應使用 `main.dart` 入口點
- Mock 模式會在 UI 上明顯標示 "MOCK MODE"
- 數據生成使用固定的演算法，不會有隨機的真實情境

---

## 相關檔案清單

### 新增檔案

- `lib/infrastructure/source/bluetooth/mock_bluetooth_module.dart` - Mock 藍牙模組
- `lib/presentation/screen/home_screen_mock.dart` - Mock 專用首頁（跳過藍牙檢查）
- `lib/presentation/view/bluetooth/bluetooth_scanner_view_mock.dart` - Mock 藍牙掃描器

### 修改檔案

- `lib/main.dart` - 添加 Mock 模式開關
- `lib/init/initializer.dart` - 支援依賴注入
- `lib/init/resource/infrastructure/bluetooth_resource.dart` - 接受動態類型

---

## 未來改進方向

1. **可設定的模擬參數** - 允許調整數據生成的頻率、範圍等
2. **情境模式** - 預設的運動情境（走路、跑步、靜止等）
3. **錯誤模擬** - 模擬連接中斷、數據錯誤等異常情況
4. **錄製/回放** - 記錄真實設備的數據並在 Mock 模式中回放

---

## 總結

Mock 資料模式的實作解決了平安符專案在開發階段「卡在藍牙頁面」的問題，讓開發者能夠：

✅ 不依賴硬體設備進行開發
✅ 快速測試 UI 和資料處理邏輯
✅ 在 CI/CD 環境中執行自動化測試
✅ 演示應用程式功能而無需準備實體設備

### 設計優點

1. **簡單易用** - 只需修改 `main.dart` 中一個 `const bool` 即可切換模式
2. **依賴注入** - 整體架構遵循依賴注入原則，保持程式碼的可測試性和可維護性
3. **無需額外檔案** - 不需要創建單獨的入口點，所有邏輯整合在 `main.dart`
4. **Hot Restart 支援** - 可以使用 Flutter Hot Restart 快速切換模式（需重新啟動）

### 快速開始

```dart
// lib/main.dart 第 24 行
const bool useMockData = true;  // ← 改這裡就好！
```

然後執行 `flutter run` 即可！
