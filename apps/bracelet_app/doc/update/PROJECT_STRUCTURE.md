# Bracelet App 專案結構

## 📂 完整檔案列表

```
lib/
├── main.dart                                           ✅ App 入口
│
├── domain/                                             ✅ Domain 層（業務邏輯）
│   └── entity/
│       └── mlx_sensor_data.dart                       ✅ MLX 感測器資料實體
│
├── infrastructure/                                     ✅ Infrastructure 層（技術實作）
│   ├── source/
│   │   ├── bluetooth/
│   │   │   ├── bracelet_bluetooth_module.dart         ✅ NUS 藍牙連接模組
│   │   │   └── bracelet_packet_parser.dart            ✅ 43 bytes 封包解析器
│   │   └── hive/
│   │       ├── hive_mlx_sensor.dart                   ✅ Hive 資料模型
│   │       └── hive_mlx_mapper.dart                   ✅ Domain ↔ Hive 轉換器
│   └── service/
│       └── csv_export_service.dart                    ✅ CSV 匯出服務
│
└── presentation/                                       ✅ Presentation 層（UI）
    ├── change_notifier/
    │   └── bracelet_change_notifier.dart              ✅ 狀態管理
    ├── screen/
    │   └── home_screen.dart                           ✅ 主畫面（含藍牙掃描對話框）
    └── view/
        ├── mlx_chart_view.dart                        ✅ 12 條波形線圖表
        └── control_panel_view.dart                    ✅ 控制面板 UI
```

## ✅ 檔案功能說明

### Domain 層
| 檔案 | 功能 | 重點 |
|-----|------|------|
| `mlx_sensor_data.dart` | MLX 感測器資料實體 | 包含 24 個欄位（ICM + 4 顆 MLX），提供 `toCsvRow()` 方法 |

### Infrastructure 層
| 檔案 | 功能 | 重點 |
|-----|------|------|
| `bracelet_bluetooth_module.dart` | NUS 藍牙連接 | 處理連接、訂閱、指令發送（a/c/d/r） |
| `bracelet_packet_parser.dart` | 封包解析 | 43 bytes，IMU 有符號，MLX 無符號，big endian |
| `hive_mlx_sensor.dart` | Hive 資料模型 | 需要 `build_runner` 生成 `.g.dart` |
| `hive_mlx_mapper.dart` | 資料轉換 | Domain Entity ↔ Hive Model |
| `csv_export_service.dart` | CSV 匯出 | 參考圖片格式，檔名 `MLX_YYYYMMDD_HHMMSS.csv` |

### Presentation 層
| 檔案 | 功能 | 重點 |
|-----|------|------|
| `bracelet_change_notifier.dart` | 狀態管理 | 管理連接、資料、記錄狀態 |
| `home_screen.dart` | 主畫面 | 包含藍牙掃描對話框 |
| `mlx_chart_view.dart` | 波形圖 | 12 條彩色波形線（4 顆 MLX × 3 軸） |
| `control_panel_view.dart` | 控制面板 | 開始/暫停、重置、指令、匯出 CSV |

## 🔧 依賴關係圖

```
main.dart
  │
  ├─> BraceletChangeNotifier
  │     │
  │     ├─> BraceletBluetoothModule
  │     │     └─> BraceletPacketParser
  │     │           └─> MlxSensorData
  │     │
  │     └─> CsvExportService
  │           └─> MlxSensorData
  │
  └─> HomeScreen
        │
        ├─> DeviceScannerDialog
        │
        ├─> MlxChartView
        │     └─> MlxSensorData (List)
        │
        └─> ControlPanelView
              └─> BraceletChangeNotifier
```

## 📊 資料流向

```
手環 (Nordic nRF52840)
  │
  │ [NUS TX Characteristic]
  │ 43 bytes 封包
  ↓
BraceletBluetoothModule
  │
  │ [解析封包]
  ↓
BraceletPacketParser
  │
  │ [建立實體]
  ↓
MlxSensorData
  │
  ├─> BraceletChangeNotifier (儲存到 List)
  │     │
  │     ├─> MlxChartView (顯示波形)
  │     └─> CsvExportService (匯出 CSV)
  │
  └─> (可選) HiveMlxSensor (儲存到資料庫)
```

## ⚙️ 核心功能實作

### 1. 藍牙連接 (NUS)
- **UUID 定義**:
  - Service: `6E400001-B5A3-F393-E0A9-E50E24DCCA9E`
  - TX: `6E400003-B5A3-F393-E0A9-E50E24DCCA9E`
  - RX: `6E400002-B5A3-F393-E0A9-E50E24DCCA9E`

### 2. 封包解析 (43 bytes)
```
Byte 0:      0x0A (標頭)
Byte 1-18:   ICM-20948 (有符號 int16, big endian)
Byte 19-42:  4 × MLX90393 (無符號 uint16, big endian)
```

### 3. 指令發送
- 'a' (0x61): 開始串流
- 'c' (0x63): 校正 IMU
- 'd' (0x64): 初始化 IMU
- 'r' (0x72): 重啟手環

### 4. CSV 匯出格式
```csv
Timestamp,MLX0_X,MLX0_Y,MLX0_Z,MLX1_X,MLX1_Y,MLX1_Z,MLX2_X,MLX2_Y,MLX2_Z,MLX3_X,MLX3_Y,MLX3_Z
```

## ✅ 程式碼檢查清單

- ✅ 無 `utl_amulet` 的 import
- ✅ 所有 import 路徑正確（使用 `bracelet_app`）
- ✅ 無未定義的類別引用
- ✅ 所有依賴都在 `pubspec.yaml` 中
- ✅ 檔案結構清晰簡潔

## 🚀 下一步

### 執行前準備
1. 在根目錄執行 `melos bootstrap`
2. (可選) 執行 `flutter packages pub run build_runner build` 生成 Hive .g.dart
3. 執行 `flutter run`

### 測試重點
1. 藍牙掃描和連接
2. 封包解析是否正確（檢查 Console 日誌）
3. 波形圖是否正常顯示
4. CSV 匯出格式是否正確

---

**專案清理完成！** ✅ 所有檔案都已檢查並修正。
