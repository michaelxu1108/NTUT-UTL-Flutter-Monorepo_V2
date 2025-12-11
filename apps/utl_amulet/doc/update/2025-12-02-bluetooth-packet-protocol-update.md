# UTL Amulet 藍牙封包協議更新

**日期**: 2025-12-02
**版本**: v2.0
**類型**: 藍牙協議重大更新

---

## 📋 更新概述

本次更新根據新版藍牙封包協議規範，對 UTL Amulet 應用程式進行了全面的協議層修改，包括位元組順序變更、新增感測器欄位、姿態類型擴充以及藍牙指令控制功能。

---

## 🔄 主要變更內容

### 1. 藍牙封包解析 - 位元組順序變更

**變更說明**: 所有 16-bit 數值從 **Little-Endian（低位元組在前）** 改為 **Big-Endian（高位元組在前）**

**影響檔案**: `lib/infrastructure/source/bluetooth/bluetooth_received_packet.dart`

**變更細節**:

```dart
// 舊版（Little-Endian）
accX: bytes.getInt16(0, Endian.little),  // [低][高]

// 新版（Big-Endian）
accX: bytes.getInt16(0, Endian.big),     // [高][低]
```

**受影響的欄位**（所有 16-bit 數值）:

- 加速度: `accX`, `accY`, `accZ`, `accTotal`
- 姿態角: `roll`, `pitch`, `yaw`
- 磁力計: `magX`, `magY`, `magZ`, `magTotal`
- 溫度: `temperature`
- 步數: `step`
- ADC: `adc`
- **新增**: `beaconRssi`

**注意**: Float32 類型的 `pressure` 欄位維持 Little-Endian 不變

---

### 2. 新增感測器資料欄位

#### 2.1 Beacon RSSI（信號強度）

**位元組位置**: [27][28]
**資料型態**: `int16` (Big-Endian)
**說明**: Beacon 訊號接收強度指示器

**新增位置**:

- `lib/domain/entity/amulet_entity.dart` - Domain Entity
- `lib/service/data_stream/amulet_sensor_data_stream.dart` - Data Stream
- `lib/infrastructure/source/hive/hive_amulet.dart` - Hive Schema (@HiveField(21))
- `lib/infrastructure/source/csv_file/amulet_csv_file.dart` - CSV Export
- `lib/adapter/usecase/save_amulet_sensor_data_to_repository_usecase.dart` - Repository

#### 2.2 Point（計分）

**位元組位置**: [36]
**資料型態**: `uint8`
**說明**: 計分欄位

**新增位置**: 同上，@HiveField(22)

---

### 3. 姿態類型 (Posture Type) 更新

#### 3.1 姿態枚舉值重新對應

**變更說明**: 調整部分姿態類型的數值對應

| 姿態類型 | 英文名稱               | 原值 | 新值  | 說明     |
| -------- | ---------------------- | ---- | ----- | -------- |
| 跌倒     | `falling`              | 7    | **5** | 向前調整 |
| 左側躺   | `leftLateralDecubitus` | 5    | **7** | 向後調整 |
| 行走     | `walking`              | 8    | **9** | 向後調整 |

**影響檔案**:

- `lib/domain/entity/amulet_entity.dart:13-27`
- `lib/infrastructure/source/hive/hive_amulet.dart:5-31`

#### 3.2 新增姿態類型

新增三個姿態類型：

| 數值 | 名稱       | 英文名稱       | 說明                 |
| ---- | ---------- | -------------- | -------------------- |
| 8    | 保留       | `reserved`     | 保留欄位             |
| 10   | 暫時不穩定 | `tempUnstable` | 姿態轉換中的暫時狀態 |
| 11   | 直立       | `upright`      | 直立站姿             |

**完整姿態列表**:

```dart
enum AmuletPostureType {
  init,                      // 0  - 初始化
  sit,                       // 1  - 坐姿
  stand,                     // 2  - 站立
  lieDown,                   // 3  - 平躺
  lieDownRight,              // 4  - 右側躺
  fallDown,                  // 5  - 跌倒（原 7）
  getDown,                   // 6  - 趴下
  lieDownLeft,               // 7  - 左側躺（原 5）
  reserved,                  // 8  - 保留（新增）
  walk,                      // 9  - 行走（原 8）
  tempUnstable,              // 10 - 暫時不穩定（新增）
  upright,                   // 11 - 直立（新增）
}
```

---

### 4. UI 文字更新

**變更說明**: 將「氣壓」術語改為更準確的「高度」

**影響檔案**:

- `l10n/app_en.arb:42` - `"pressure": "altitude"`
- `l10n/app_zh.arb:42` - `"pressure": "高度"`
- `l10n/app_zh_tw.arb:42` - `"pressure": "高度"`

**新增多語系翻譯**:

```json
// 英文
"beaconRssi": "beacon RSSI",
"point": "point"

// 簡體中文
"beaconRssi": "信标信号强度",
"point": "计分"

// 繁體中文
"beaconRssi": "信標訊號強度",
"point": "計分"
```

---

### 5. 藍牙指令寫入功能

**新增功能**: 透過 Nordic UART Service (NUS) 發送控制指令

**影響檔案**:

- `lib/infrastructure/resource/bluetooth_resource.dart` - 新增 `sendCommand` 方法
- `lib/presentation/view/amulet/amulet_buttons_board.dart` - 新增 UI 輸入元件

#### 5.1 支援的指令列表

| 指令碼 | 功能說明      |
| ------ | ------------- |
| `0x60` | 切換 BLE 模式 |
| `0x61` | 設定參數 1    |
| `0x62` | 設定參數 2    |
| `0x63` | 設定參數 3    |
| `0x64` | 校準          |
| `0x65` | 磁力計校準    |

#### 5.2 實作方式

```dart
// BluetoothResource 新增方法
Future<bool> sendCommand({required String command}) async {
  try {
    // 解析 hex 字串 (例如 "0x61" 或 "61")
    final hexString = command.startsWith('0x')
        ? command.substring(2)
        : command;
    final value = int.parse(hexString, radix: 16);

    // 透過 NUS TX characteristic 寫入
    await _nusTxCharacteristic?.write([value]);
    return true;
  } catch (e) {
    return false;
  }
}
```

#### 5.3 UI 控制面板

**位置**: `lib/presentation/view/amulet/amulet_buttons_board.dart:187-245`

**功能**:

- 文字輸入框支援 hex 格式（如 `0x61`）
- 發送按鈕執行指令
- Toast 提示發送成功/失敗

```dart
class _BluetoothCommandInput extends StatefulWidget {
  // TextField for hex input
  // Send button triggers sendCommand
  // Toast notification for user feedback
}
```

---

### 6. 資料庫架構更新

#### 6.1 Hive Schema 變更

**檔案**: `lib/infrastructure/source/hive/hive_amulet.dart`

**新增欄位**:

```dart
@HiveField(21)
final int beaconRssi;  // Beacon 訊號強度

@HiveField(22)
final int point;       // 計分欄位
```

**姿態枚舉更新**: 如第 3 節所述

#### 6.2 Hive Adapter 生成

**檔案**: `lib/infrastructure/source/hive/hive_amulet.g.dart`（手動生成）

**重要變更**:

- `HiveAmuletEntity` 欄位數量: 21 → **23**
- 新增 `beaconRssi` (field 21) 和 `point` (field 22) 的序列化/反序列化邏輯
- 更新 `HiveAmuletPostureType` adapter 以支援 12 種姿態類型（0-11）

```dart
@override
void write(BinaryWriter writer, HiveAmuletEntity obj) {
  writer
    ..writeByte(23)  // 總共 23 個欄位
    // ... 原有欄位
    ..writeByte(21)
    ..write(obj.beaconRssi)
    ..writeByte(22)
    ..write(obj.point);
}
```

---

### 7. CSV 匯出功能更新

**檔案**: `lib/infrastructure/source/csv_file/amulet_csv_file.dart`

**新增欄位**:

- 標題列新增 `beaconRssi` 和 `point` 欄位名稱（第 53, 59 行）
- 資料列新增對應數值輸出（第 99, 105 行）

**欄位順序**:

```
id, deviceId, time, accX, accY, accZ, accTotal,
magX, magY, magZ, magTotal, pitch, roll, yaw,
pressure(altitude), temperature, posture,
beaconRssi, adc, battery, area, step, direction, point
```

---

### 8. Mapper 層更新

**檔案**: `lib/infrastructure/source/hive/hive_mapper.dart`

**變更內容**:

- 在 `fromAmuletEntity` 方法中新增 `beaconRssi` 和 `point` 欄位對應（第 33-34 行）
- 在 `toAmuletEntity` 方法中新增欄位轉換（第 65-66 行）

---

## 📊 完整封包格式對照表

| Byte 位置    | 欄位名稱       | 型態      | 位元組順序 | 說明                        |
| ------------ | -------------- | --------- | ---------- | --------------------------- |
| [0][1]       | accX           | int16     | **Big**    | 加速度 X 軸                 |
| [2][3]       | accY           | int16     | **Big**    | 加速度 Y 軸                 |
| [4][5]       | accZ           | int16     | **Big**    | 加速度 Z 軸                 |
| [6][7]       | accTotal       | uint16    | **Big**    | 加速度總量                  |
| [8][9]       | roll           | int16     | **Big**    | 滾轉角                      |
| [10][11]     | pitch          | int16     | **Big**    | 俯仰角                      |
| [12][13]     | yaw            | int16     | **Big**    | 偏航角                      |
| [14][15]     | magX           | int16     | **Big**    | 磁力計 X 軸                 |
| [16][17]     | magY           | int16     | **Big**    | 磁力計 Y 軸                 |
| [18][19]     | magZ           | int16     | **Big**    | 磁力計 Z 軸                 |
| [20][21]     | magTotal       | uint16    | **Big**    | 磁力計總量                  |
| [22][23]     | _reserved_     | -         | -          | 保留欄位                    |
| [24][25]     | temperature    | uint16    | **Big**    | 溫度                        |
| [26]         | posture        | uint8     | -          | 姿態類型（0-11）            |
| **[27][28]** | **beaconRssi** | **int16** | **Big**    | **Beacon 訊號強度（新增）** |
| [29]         | direction      | uint8     | -          | 方向                        |
| [30][31]     | adc            | int16     | **Big**    | ADC 數值                    |
| [32]         | battery        | uint8     | -          | 電池電量                    |
| [33]         | area           | uint8     | -          | 區域                        |
| [34][35]     | step           | int16     | **Big**    | 步數                        |
| **[36]**     | **point**      | **uint8** | **-**      | **計分（新增）**            |
| [37]         | _reserved_     | -         | -          | 保留欄位                    |
| [38-41]      | pressure       | float32   | Little     | 氣壓（顯示為高度）          |

**封包最小長度**: 37 bytes（新增欄位後）
**完整封包長度**: 42 bytes（含 pressure）

---

## 🔧 技術實作細節

### 位元組順序轉換注意事項

**Big-Endian 範例**:

```
原始資料（十六進位）: 0x01 0x23
Big-Endian 解析: (0x01 << 8) | 0x23 = 0x0123 = 291
```

**Little-Endian 範例**（舊版）:

```
原始資料（十六進位）: 0x01 0x23
Little-Endian 解析: (0x23 << 8) | 0x01 = 0x2301 = 8961
```

**重要提醒**: 請確保韌體端同步更新為 Big-Endian，否則數值會錯誤！

---

## ✅ 測試建議

### 1. 藍牙封包解析測試

- [ ] 驗證 16-bit 數值正確性（與韌體端數值比對）
- [ ] 確認 Beacon RSSI 讀取正常
- [ ] 確認 Point 欄位讀取正常
- [ ] 測試新增的姿態類型是否正確識別

### 2. 資料庫測試

- [ ] 清除舊資料庫後重新儲存
- [ ] 確認 Hive 儲存/讀取新欄位無誤
- [ ] 驗證姿態枚舉值對應正確

### 3. CSV 匯出測試

- [ ] 匯出 CSV 檔案
- [ ] 確認標題列包含 beaconRssi 和 point
- [ ] 確認數值欄位完整且正確

### 4. 藍牙指令測試

- [ ] 測試發送各種指令（0x60-0x65）
- [ ] 確認韌體端收到指令並執行
- [ ] 驗證錯誤處理機制

### 5. UI 測試

- [ ] 確認「氣壓」已改為「高度」
- [ ] 確認 beaconRssi 和 point 欄位顯示
- [ ] 測試指令輸入介面

---

## 📁 修改檔案清單

### Domain Layer

- `lib/domain/entity/amulet_entity.dart` - 新增欄位、更新枚舉

### Infrastructure Layer

- `lib/infrastructure/source/bluetooth/bluetooth_received_packet.dart` - 位元組順序、新欄位解析
- `lib/infrastructure/source/hive/hive_amulet.dart` - Schema 更新
- `lib/infrastructure/source/hive/hive_amulet.g.dart` - **手動生成** Adapter
- `lib/infrastructure/source/hive/hive_mapper.dart` - Mapper 更新
- `lib/infrastructure/source/csv_file/amulet_csv_file.dart` - CSV 欄位新增
- `lib/infrastructure/resource/bluetooth_resource.dart` - 新增指令發送功能

### Service Layer

- `lib/service/data_stream/amulet_sensor_data_stream.dart` - 新增欄位

### Adapter Layer

- `lib/adapter/usecase/save_amulet_sensor_data_to_repository_usecase.dart` - 新增欄位參數

### Presentation Layer

- `lib/presentation/view/amulet/amulet_buttons_board.dart` - 新增指令輸入 UI

### Localization

- `l10n/app_en.arb` - 英文翻譯更新
- `l10n/app_zh.arb` - 簡體中文翻譯更新
- `l10n/app_zh_tw.arb` - 繁體中文翻譯更新

**總計**: 13 個檔案

---

## ⚠️ 注意事項與建議

### 1. 資料庫遷移

由於 Hive schema 有重大變更（新增欄位、枚舉值調整），建議：

- 清除舊版本的 Hive 資料庫
- 或實作資料遷移邏輯
- **風險**: 直接讀取舊資料可能造成欄位錯位

### 2. 韌體協議同步

- 確認韌體端已同步更新為 Big-Endian
- 確認 Beacon RSSI 和 Point 欄位已實作
- 確認姿態類型數值對應正確

### 3. 向後相容性

- 本次更新**不向後相容**舊版藍牙封包
- 需同步更新韌體和 App

### 4. 錯誤處理

- 封包長度檢查: 至少 37 bytes
- 姿態類型範圍檢查: 0-11
- Hex 指令輸入驗證

---

## 📈 效能影響

- ✅ 封包解析效能: 無明顯影響（僅改變位元組順序）
- ✅ 資料庫大小: 每筆資料增加約 3 bytes（beaconRssi 2 bytes + point 1 byte）
- ✅ CSV 檔案大小: 每列增加約 10-20 characters

---

## 🎯 後續工作

1. **韌體整合測試**: 與硬體團隊協同測試新協議
2. **資料視覺化**: 考慮新增 Beacon RSSI 和 Point 的圖表顯示
3. **指令擴充**: 根據需求新增更多控制指令
4. **文件更新**: 更新使用手冊和 API 文件

---
