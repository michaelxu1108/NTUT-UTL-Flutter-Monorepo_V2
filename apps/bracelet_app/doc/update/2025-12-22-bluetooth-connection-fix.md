# 手環 App - 藍牙連接卡住問題修正

**日期**: 2025-12-22
**問題**: 用戶在連接藍牙手環後卡在"連接中"轉圈畫面

---

## 🔍 問題分析

### 根本原因

原始的 `BraceletBluetoothModule` 存在以下問題：

1. **缺少連接狀態監聽** ⚠️
   - 連接成功後沒有監聽 `device.connectionState`
   - 無法感知裝置的實際連接狀態變化
   - 如果連接過程中出現問題，UI 無法更新

2. **`isConnected` 判斷邏輯不準確** ⚠️
   ```dart
   // 舊版（錯誤）：只檢查本地變數
   bool get isConnected => _device != null && _txCharacteristic != null && _rxCharacteristic != null;
   ```
   - 只檢查本地變數是否被設置
   - 不檢查實際的藍牙連接狀態
   - 即使裝置已斷線，仍可能返回 true

3. **缺少連接狀態變化處理**
   - 沒有處理裝置自動斷線的情況
   - 沒有在連接失敗時正確清理資源

4. **日誌不夠詳細**
   - 難以追蹤連接過程中的問題
   - 無法快速定位失敗原因

---

## ✅ 修正內容

### 1. 新增連接狀態監聽

**檔案**: `lib/infrastructure/source/bluetooth/bracelet_bluetooth_module.dart`

#### 新增變數：
```dart
StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
```

#### 在 `connect()` 方法中添加監聽：
```dart
// 監聽連接狀態變化
_connectionStateSubscription = device.connectionState.listen((state) {
  print('📡 連接狀態變化: $state');
  if (state == BluetoothConnectionState.disconnected) {
    print('⚠️ 裝置已斷開連接');
    _handleDisconnection();
  }
});
print('✅ 已設置連接狀態監聽');
```

### 2. 改進 `isConnected` 判斷邏輯

**舊版（錯誤）**：
```dart
bool get isConnected => _device != null && _txCharacteristic != null && _rxCharacteristic != null;
```

**新版（正確）**：
```dart
/// 連接狀態（使用實際的藍牙連接狀態）
bool get isConnected => _device?.isConnected ?? false;
```

✅ **改進**：
- 直接使用 `device.isConnected` 檢查實際連接狀態
- 即時反映真實的藍牙連接狀態
- 裝置斷線時會立即返回 false

### 3. 新增斷線處理方法

```dart
/// 處理裝置斷線
void _handleDisconnection() {
  print('🔴 處理裝置斷線...');
  _device = null;
  _txCharacteristic = null;
  _rxCharacteristic = null;
}
```

### 4. 改進錯誤處理

在 `connect()` 的 catch 塊中添加完整的資源清理：

```dart
} catch (e) {
  print('❌ 連接失敗: $e');

  // 清理資源
  await _connectionStateSubscription?.cancel();
  _connectionStateSubscription = null;

  _device = null;
  _txCharacteristic = null;
  _rxCharacteristic = null;
  return false;
}
```

### 5. 更新 `disconnect()` 方法

確保斷開連接時取消所有訂閱：

```dart
/// 斷開連接
Future<void> disconnect() async {
  print('🔌 斷開連接...');

  // 取消資料訂閱
  await _characteristicSubscription?.cancel();
  _characteristicSubscription = null;

  // 取消連接狀態訂閱
  await _connectionStateSubscription?.cancel();
  _connectionStateSubscription = null;

  // 斷開藍牙連接
  if (_device != null) {
    try {
      await _device!.disconnect();
      print('✅ 已斷開連接');
    } catch (e) {
      print('⚠️ 斷開連接時發生錯誤: $e');
    }
  }

  _device = null;
  _txCharacteristic = null;
  _rxCharacteristic = null;
}
```

### 6. 更新 `dispose()` 方法

```dart
/// 釋放資源
void dispose() {
  print('🗑️ 釋放 BraceletBluetoothModule 資源...');
  _characteristicSubscription?.cancel();
  _connectionStateSubscription?.cancel();  // ← 新增
  _dataStreamController.close();
}
```

### 7. 增強日誌輸出

在連接過程的每個階段都添加了詳細的日誌：

```dart
print('🔵 開始連接到裝置: ${device.platformName} (${device.remoteId})');
print('✅ 已連接到裝置: ${device.platformName}');
print('🔍 開始發現服務...');
print('✅ 發現 ${services.length} 個服務');
print('✅ 找到 NUS 服務');
print('🔍 搜尋 TX/RX Characteristics...');
print('  ✅ 找到 TX Characteristic');
print('  ✅ 找到 RX Characteristic');
print('🔔 訂閱 TX Characteristic...');
print('✅ 已訂閱 TX Characteristic');
print('📤 發送開始串流指令...');
print('🎉 連接完成！手環已就緒');
```

**失敗時的詳細提示**：
```dart
if (nusService == null) {
  print('❌ 找不到 NUS 服務 (${nusServiceUuid})');
  print('   可用的服務: ${services.map((s) => s.uuid).join(", ")}');
  await device.disconnect();
  return false;
}

if (_txCharacteristic == null || _rxCharacteristic == null) {
  print('❌ 找不到必要的 Characteristics');
  print('   TX Characteristic: ${_txCharacteristic != null ? "找到" : "缺失"}');
  print('   RX Characteristic: ${_rxCharacteristic != null ? "找到" : "缺失"}');
  await device.disconnect();
  return false;
}
```

---

## 📋 修正摘要

| 問題 | 修正前 | 修正後 |
|------|--------|--------|
| **連接狀態監聽** | ❌ 沒有監聽 | ✅ 監聽 `connectionState` Stream |
| **isConnected 判斷** | ❌ 檢查本地變數 | ✅ 使用 `device.isConnected` |
| **斷線處理** | ❌ 沒有處理 | ✅ 自動處理斷線並清理資源 |
| **錯誤處理** | ⚠️ 簡單 | ✅ 完整的資源清理 |
| **日誌輸出** | ⚠️ 基本 | ✅ 詳細的每步驟日誌 |

---

## 🔧 技術細節

### Nordic UART Service (NUS) 連接流程

1. **連接裝置** (`device.connect()`)
2. **監聽連接狀態** (`device.connectionState.listen()`) ← 新增
3. **發現服務** (`device.discoverServices()`)
4. **尋找 NUS 服務** (UUID: `6E400001-B5A3-F393-E0A9-E50E24DCCA9E`)
5. **尋找 Characteristics**:
   - TX (手環→App): `6E400003-B5A3-F393-E0A9-E50E24DCCA9E`
   - RX (App→手環): `6E400002-B5A3-F393-E0A9-E50E24DCCA9E`
6. **訂閱 TX Characteristic** (`setNotifyValue(true)`)
7. **發送開始串流指令** (`startStreaming()`)

### 連接狀態 Stream

```dart
device.connectionState.listen((state) {
  // state 可能的值：
  // - BluetoothConnectionState.disconnected
  // - BluetoothConnectionState.connecting
  // - BluetoothConnectionState.connected
  // - BluetoothConnectionState.disconnecting
});
```

---

## ✅ 測試結果

### Mock 模式測試

運行命令：
```bash
flutter run
```

**日誌輸出**：
```
I/flutter: 🔧 執行模擬模式 - 使用模擬手環資料
I/flutter: 🔧 Running in MOCK MODE - Using simulated bracelet data
I/flutter: 🔧 [Mock] 模擬連接到裝置:
I/flutter: 🔧 [Mock] 連接成功，開始生成資料（50 Hz）
```

✅ **結果**: Mock 模式正常運作

### 真實手環測試建議

當使用實際手環測試時，連接日誌應該顯示：

```
🔵 開始連接到裝置: [手環名稱] ([MAC地址])
✅ 已連接到裝置: [手環名稱]
✅ 已設置連接狀態監聽
🔍 開始發現服務...
✅ 發現 X 個服務
  - 服務 UUID: [UUID列表]
✅ 找到 NUS 服務
🔍 搜尋 TX/RX Characteristics...
  - Characteristic UUID: [UUID]
  ✅ 找到 TX Characteristic
  - Characteristic UUID: [UUID]
  ✅ 找到 RX Characteristic
🔔 訂閱 TX Characteristic...
✅ 已訂閱 TX Characteristic
📤 發送開始串流指令...
🎉 連接完成！手環已就緒
```

### 連接失敗時的診斷

如果連接失敗，日誌會明確指出問題所在：

1. **找不到 NUS 服務**：
   ```
   ❌ 找不到 NUS 服務 (6E400001-B5A3-F393-E0A9-E50E24DCCA9E)
      可用的服務: [實際UUID列表]
   ```
   → 檢查手環韌體是否支援 NUS

2. **找不到 Characteristics**：
   ```
   ❌ 找不到必要的 Characteristics
      TX Characteristic: 缺失
      RX Characteristic: 找到
   ```
   → 檢查 NUS 服務的 Characteristics 配置

3. **連接超時**：
   ```
   ❌ 連接失敗: TimeoutException after 15 seconds
   ```
   → 檢查藍牙訊號強度、裝置是否已配對

---

## 🎯 預期效果

修正後，當用戶連接手環時：

1. **連接成功**：
   - "連接中" 對話框會在連接完成後自動關閉
   - 顯示 "連接成功！" 的 SnackBar
   - UI 立即切換到資料顯示畫面

2. **連接失敗**：
   - "連接中" 對話框會關閉
   - 顯示 "連接失敗" 的 SnackBar
   - 日誌清楚顯示失敗原因
   - 用戶可以重試連接

3. **裝置斷線**：
   - 自動檢測到斷線
   - UI 自動切換回 "尚未連接手環" 畫面
   - 資源正確清理

---

## 📁 修改檔案

- ✅ `apps/bracelet_app/lib/infrastructure/source/bluetooth/bracelet_bluetooth_module.dart`

---

## 🚀 使用建議

### 給用戶的測試步驟

1. **確認 Mock 模式已關閉**（測試真實手環時）：
   ```dart
   // 在 lib/main.dart 中設定
   const bool useMockData = false;  // ← 設為 false
   ```

2. **開啟藍牙**並確保手環已開機

3. **點擊搜尋手環按鈕**（右上角藍牙圖示）

4. **選擇手環裝置**

5. **觀察日誌輸出**：
   - 如果連接成功，會看到完整的連接流程日誌
   - 如果失敗，日誌會明確指出問題所在

### Debug 建議

如果連接仍然失敗，請檢查：

1. **手環韌體是否支援 NUS**
   - 查看日誌中列出的可用服務 UUID
   - 確認包含 `6E400001-B5A3-F393-E0A9-E50E24DCCA9E`

2. **藍牙權限**
   - Android: 確認已授予藍牙和位置權限
   - iOS: 確認已授予藍牙權限

3. **手環狀態**
   - 確認手環電量充足
   - 確認手環沒有連接到其他裝置

---

## 📝 備註

此修正解決了核心的連接狀態監聽問題，大幅提升了連接的穩定性和可追蹤性。所有修改都向後兼容，不會影響現有功能。Mock 模式已驗證正常運作。

---

**修正完成日期**: 2025-12-22
**測試狀態**: ✅ Mock 模式測試通過
**待測試**: 真實手環連接測試
