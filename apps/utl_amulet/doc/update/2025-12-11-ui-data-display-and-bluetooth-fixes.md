# UTL 平安符 App - UI 數據顯示與藍牙功能更新

**日期**: 2025-12-11
**版本**: 1.0.0
**作者**: MichaelXu

---

## 概述

本次更新根據用戶需求文檔（`20251211utl_amulet_修改需求.pdf`）進行了多項功能增強和問題修復，主要包括：

1. 新增 Beacon RSSI 和 Point 數據顯示
2. 姿態數值顯示改為名稱標識
3. 更新藍牙指令說明文字
4. 過濾掉未知裝置（Unknown Device）
5. 修復切換頁面後已連接裝置消失的問題

---

## 主要變更

### 1. 新增 Beacon RSSI 和 Point 數據顯示

#### 問題描述

CSV 檔案中包含 Beacon RSSI [位元組 27-28] 和 Point [位元組 36] 數據，但介面上沒有顯示這些資訊。

#### 解決方案

在數據映射器中新增這兩個資料項目，使其在儀表板上可見。

#### 修改檔案

**1. `lib/presentation/change_notifier/amulet/mapper/item.dart`**

```dart
enum AmuletLineChartItem {
  accX,
  accY,
  accZ,
  accTotal,
  magX,
  magY,
  magZ,
  magTotal,
  pitch,
  roll,
  yaw,
  pressure,
  temperature,
  posture,
  beaconRssi,  // 新增
  point,       // 新增
  adc,
  battery,
  area,
  step,
  direction,
}
```

**2. `lib/presentation/change_notifier/amulet/mapper/data_list.dart`**

```dart
num amuletLineChartItemToData({
  required AmuletLineChartItem item,
  required AmuletSensorData data,
}) {
  switch (item) {
    // ... 其他項目
    case AmuletLineChartItem.beaconRssi:
      return data.beaconRssi;  // 新增
    case AmuletLineChartItem.point:
      return data.point;  // 新增
    // ... 其他項目
  }
}
```

**3. `lib/presentation/change_notifier/amulet/mapper/name.dart`**

```dart
String amuletLineChartItemToName({
  required AmuletLineChartItem item,
  required AppLocalizations appLocalizations,
}) {
  switch (item) {
    // ... 其他項目
    case AmuletLineChartItem.beaconRssi:
      return appLocalizations.beaconRssi;  // 新增
    case AmuletLineChartItem.point:
      return appLocalizations.point;  // 新增
    // ... 其他項目
  }
}
```

**4. `lib/presentation/change_notifier/amulet/mapper/color.dart`**

```dart
const Map<AmuletLineChartItem, Color> _amuletSeriesItemColors = {
  // ... 其他顏色
  AmuletLineChartItem.beaconRssi: Color(0xFF06FFA5), // 螢光綠
  AmuletLineChartItem.point: Color(0xFFFFD60A),      // 金黃
  // ... 其他顏色
};
```

**5. 國際化檔案更新**

- `lib/l10n/app_zh_tw.arb`: `"beaconRssi": "信號強度"`, `"point": "點位"`
- `lib/l10n/app_zh.arb`: `"beaconRssi": "信号强度"`, `"point": "点位"`
- `lib/l10n/app_en.arb`: `"beaconRssi": "beacon RSSI"`, `"point": "point"`

#### 結果

現在在「數據列表」頁面可以看到 Beacon RSSI 和 Point 的即時數值。

---

### 2. 顯示姿態數字對應的名稱

#### 問題描述

姿態數據在介面上只顯示數字（0-11），使用者難以理解各數字代表的姿態類型。

#### 解決方案

創建姿態類型到名稱的映射函數，在顯示時自動轉換為可讀的名稱格式。

#### 姿態映射表

| 數字 | 姿態名稱 | 英文名稱       |
| ---- | -------- | -------------- |
| 0    | 初始化   | Init           |
| 1    | 坐姿     | Sit            |
| 2    | 站姿     | Stand          |
| 3    | 躺下     | Lie_Down       |
| 4    | 右側躺   | Lie_Down_Right |
| 5    | 跌倒     | Fall_Down      |
| 6    | 蹲下     | Get_Down       |
| 7    | 左側躺   | Lie_Down_Left  |
| 8    | 行走     | Walk           |
| 9    | 保留     | Reserved       |
| 10   | 暫態不穩 | Temp_Unstable  |
| 11   | 直立     | Upright        |

#### 修改檔案

**1. `lib/domain/entity/amulet_entity.dart`**

修正了姿態枚舉順序，確保與文檔規格一致：

```dart
enum AmuletPostureType {
  init,           // 0
  sit,            // 1
  stand,          // 2
  lieDown,        // 3
  lieDownRight,   // 4
  fallDown,       // 5
  getDown,        // 6
  lieDownLeft,    // 7
  walk,           // 8
  reserved,       // 9 (保留)
  tempUnstable,   // 10
  upright,        // 11
}
```

**2. `lib/presentation/view/amulet/amulet_dashboard.dart`**

新增姿態轉換函數：

```dart
String _postureTypeToString(AmuletPostureType posture) {
  switch (posture) {
    case AmuletPostureType.init:
      return 'Init (0)';
    case AmuletPostureType.sit:
      return 'Sit (1)';
    case AmuletPostureType.stand:
      return 'Stand (2)';
    case AmuletPostureType.lieDown:
      return 'Lie_Down (3)';
    case AmuletPostureType.lieDownRight:
      return 'Lie_Down_Right (4)';
    case AmuletPostureType.fallDown:
      return 'Fall_Down (5)';
    case AmuletPostureType.getDown:
      return 'Get_Down (6)';
    case AmuletPostureType.lieDownLeft:
      return 'Lie_Down_Left (7)';
    case AmuletPostureType.walk:
      return 'Walk (8)';
    case AmuletPostureType.reserved:
      return 'Reserved (9)';
    case AmuletPostureType.tempUnstable:
      return 'Temp_Unstable (10)';
    case AmuletPostureType.upright:
      return 'Upright (11)';
  }
}
```

修改顯示邏輯：

```dart
String yData = "";
if (sensorData != null) {
  if (item == AmuletLineChartItem.posture) {
    // 顯示姿態名稱而不是數字
    yData = _postureTypeToString(sensorData.posture);
  } else {
    yData = lineChartManager.getData(data: sensorData, item: item).toStringAsFixed(2);
  }
}
```

#### 結果

姿態項目現在顯示為 `Init (0)` 而不是單純的 `0.00`，更加直觀易懂。

---

### 3. 更新藍牙指令說明文字（0x61-0x65）

#### 問題描述

控制面板中 0x61-0x65 指令的說明文字不夠具體，需要更新為更明確的描述。

#### 原有說明

- 0x61: 設定參數
- 0x62: 設定參數
- 0x63: 設定參數
- 0x64: 校正
- 0x65: 磁力計

#### 更新後說明

- 0x61: 姿態變更為坐姿
- 0x62: 姿態變更為站姿
- 0x63: 姿態變更為 Init
- 0x64: 加速度陀螺儀校正
- 0x65: 磁力計校正

#### 修改檔案

**國際化檔案更新**

所有三個語言版本都新增了對應的翻譯鍵：

- `commandSetSitPosture`
- `commandSetStandPosture`
- `commandSetInitPosture`
- `commandAccGyroCalibrate`
- `commandMagnetometerCalibrate`

**`lib/presentation/view/amulet/amulet_control_panel.dart`**

```dart
_buildCommandItem('61', appLocalizations.commandSetSitPosture),
_buildCommandItem('62', appLocalizations.commandSetStandPosture),
_buildCommandItem('63', appLocalizations.commandSetInitPosture),
_buildCommandItem('64', appLocalizations.commandAccGyroCalibrate),
_buildCommandItem('65', appLocalizations.commandMagnetometerCalibrate),
```

#### 結果

控制面板的指令說明更加清晰明確，使用者可以直接了解每個指令的具體功能。

---

### 4. 過濾掉未知裝置（Unknown Device）

#### 問題描述

藍牙掃描結果中會出現多個 "Unknown Device"（沒有設備名稱的裝置），這些裝置對使用者沒有意義，造成列表混亂。

#### 解決方案

在掃描結果處理時過濾掉所有沒有設備名稱（`platformName.isEmpty`）的裝置。

#### 修改檔案

**`lib/presentation/view/bluetooth/bluetooth_scanner_view.dart`**

```dart
// Listen to scan results
fbp.FlutterBluePlus.scanResults.listen((results) {
  if (mounted) {
    setState(() {
      // 過濾掉 Unknown Device（沒有設備名稱的裝置）
      _scanResults = results.where((result) {
        return result.device.platformName.isNotEmpty;
      }).toList();
    });
  }
});
```

#### 結果

掃描列表只顯示有名稱的裝置，介面更加清爽易用。

---

### 5. 修復切換頁面後已連接裝置消失的問題

#### 問題描述

使用者在藍牙掃描頁面連接裝置後，切換到「數據列表」或「控制面板」頁面，再回到藍牙掃描頁面時，已連接的裝置會從列表中消失，無法執行斷開連接操作。

#### 原因分析

1. 藍牙掃描超時（15 秒）後會停止掃描
2. 已連接的裝置不再出現在新的掃描結果中
3. 頁面重建時只顯示掃描結果，沒有保留已連接裝置的資訊

#### 解決方案

1. 追蹤已連接的裝置列表
2. 在頁面初始化和刷新時載入已連接裝置
3. 合併顯示掃描結果和已連接裝置（避免重複）

#### 修改檔案

**`lib/presentation/view/bluetooth/bluetooth_scanner_view.dart`**

新增狀態變數：

```dart
class _BluetoothScannerViewState extends State<BluetoothScannerView> {
  List<fbp.ScanResult> _scanResults = [];
  List<fbp.BluetoothDevice> _connectedDevices = [];  // 新增
  bool _isScanning = false;
```

新增載入已連接裝置的方法：

```dart
void _loadConnectedDevices() {
  // 獲取所有已連接的設備
  _connectedDevices = fbp.FlutterBluePlus.connectedDevices;
}

@override
void initState() {
  super.initState();
  _loadConnectedDevices();  // 初始化時載入
  _startScan();
}
```

合併顯示邏輯：

```dart
@override
Widget build(BuildContext context) {
  // 合併掃描結果和已連接設備
  final allDevices = <fbp.BluetoothDevice>[];
  final deviceIds = <String>{};

  // 先添加已連接的設備
  for (final device in _connectedDevices) {
    allDevices.add(device);
    deviceIds.add(device.remoteId.str);
  }

  // 再添加掃描結果中的設備（避免重複）
  for (final result in _scanResults) {
    if (!deviceIds.contains(result.device.remoteId.str)) {
      allDevices.add(result.device);
      deviceIds.add(result.device.remoteId.str);
    }
  }

  return Scaffold(
    // ... 使用 allDevices 而不是 _scanResults
  );
}
```

刷新按鈕更新：

```dart
IconButton(
  icon: Icon(_isScanning ? Icons.stop : Icons.refresh),
  onPressed: () {
    if (_isScanning) {
      _stopScan();
    } else {
      _loadConnectedDevices();  // 刷新時重新載入
      _startScan();
    }
  },
),
```

#### 結果

- 已連接的裝置始終顯示在列表中
- 切換頁面後回來，仍可看到已連接裝置並執行斷開連接
- 避免重複顯示同一裝置

---

## 技術細節

### 數據流程圖

```
藍牙裝置
    ↓
BluetoothReceivedPacket (解析封包)
    ↓
AmuletSensorData (資料模型)
    ↓
AmuletLineChartManagerChangeNotifier (狀態管理)
    ↓
AmuletDashboard (UI 顯示)
    ↓
使用者看到的數據（包含 beaconRssi, point, 姿態名稱）
```

### 檔案結構

```
lib/
├── domain/
│   └── entity/
│       └── amulet_entity.dart                    # 姿態枚舉修正
├── presentation/
│   ├── change_notifier/
│   │   └── amulet/
│   │       └── mapper/
│   │           ├── item.dart                     # 新增 beaconRssi, point
│   │           ├── data_list.dart                # 數據映射更新
│   │           ├── name.dart                     # 名稱映射更新
│   │           └── color.dart                    # 顏色配置更新
│   └── view/
│       ├── amulet/
│       │   ├── amulet_dashboard.dart             # 姿態名稱顯示邏輯
│       │   └── amulet_control_panel.dart         # 指令說明更新
│       └── bluetooth/
│           └── bluetooth_scanner_view.dart       # 過濾與連接修復
└── l10n/
    ├── app_zh_tw.arb                             # 繁體中文翻譯
    ├── app_zh.arb                                # 簡體中文翻譯
    └── app_en.arb                                # 英文翻譯
```

---

## 測試結果

### 功能測試

✅ Beacon RSSI 數據正確顯示在儀表板
✅ Point 數據正確顯示在儀表板
✅ 姿態顯示為名稱格式（例如：`Sit (1)`）
✅ 藍牙指令說明文字已更新
✅ Unknown Device 不再顯示在掃描列表
✅ 切換頁面後已連接裝置仍然可見
✅ 可正常斷開已連接的裝置

### 代碼分析

```bash
flutter analyze
```

結果：**No issues found!** ✅

---

## 已知問題

無。

---

## 後續工作建議

1. **數據持久化**: 考慮將連接過的裝置歷史記錄保存到本地
2. **自動重連**: 實現應用啟動時自動連接上次使用的裝置
3. **姿態警報**: 針對特定姿態（如跌倒）添加警報通知功能
4. **數據可視化**: 為 Beacon RSSI 添加圖表顯示，觀察信號強度變化趨勢

---

## 相關資源

- 需求文檔: `doc/20251211utl_amulet_修改需求.pdf`
- flutter_blue_plus 文檔: https://pub.dev/packages/flutter_blue_plus
- Flutter 國際化指南: https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization

---

## 變更檔案清單

### 核心功能

- `lib/domain/entity/amulet_entity.dart`
- `lib/presentation/change_notifier/amulet/mapper/item.dart`
- `lib/presentation/change_notifier/amulet/mapper/data_list.dart`
- `lib/presentation/change_notifier/amulet/mapper/name.dart`
- `lib/presentation/change_notifier/amulet/mapper/color.dart`
- `lib/presentation/view/amulet/amulet_dashboard.dart`
- `lib/presentation/view/amulet/amulet_control_panel.dart`
- `lib/presentation/view/bluetooth/bluetooth_scanner_view.dart`

### 國際化

- `lib/l10n/app_zh_tw.arb`
- `lib/l10n/app_zh.arb`
- `lib/l10n/app_en.arb`
- `l10n/app_zh_tw.arb`
- `l10n/app_zh.arb`
- `l10n/app_en.arb`

### 配置

- `apps/bracelet_app/pubspec.yaml` (修正 workspace 配置)

---

**總計變更**: 17 個檔案
**新增功能**: 5 項
**修復問題**: 2 項
**代碼行數**: 約 +180 行
