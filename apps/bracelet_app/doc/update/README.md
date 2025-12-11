# 手環感測器監控 App

基於 Nordic nRF52840 手環的 MLX90393 磁力計即時監控應用程式。

## 📋 功能特色

### 即時監控
- **12 條波形線同步顯示**：4 顆 MLX90393 磁力計（I2C 0x0C ~ 0x0F）的 X/Y/Z 軸
- **Arduino 風格即時繪圖**：最近 100 筆資料點即時更新
- **50 Hz 資料採樣率**：每秒接收 50 個封包

### 手環控制
- **開始/暫停記錄**：控制資料記錄狀態
- **校正 IMU** ('c')：發送校正指令到手環
- **初始化 IMU** ('d')：重新初始化姿態 filter
- **重啟手環** ('r')：遠端重開機
- **重置**：清除所有資料和波形

### 資料匯出
- **CSV 格式匯出**：按照標準格式匯出
- **檔案格式**：`MLX_YYYYMMDD_HHMMSS.csv`
- **欄位**：Timestamp, MLX0_X, MLX0_Y, MLX0_Z, ..., MLX3_Z

## 🚀 開始使用

### 1. 安裝依賴

在專案根目錄執行：

```bash
cd /Users/xuguanwen/Desktop/Projects/flutter/NTUT-UTL-Flutter-Monorepo_editV2
melos bootstrap
```

### 2. 生成 Hive 程式碼（如果需要）

```bash
cd apps/bracelet_app
flutter packages pub run build_runner build
```

### 3. 執行 App

```bash
flutter run
```

## 📱 使用流程

1. **開啟 App** → 點擊「搜尋手環」
2. **選擇裝置** → 從列表中選擇手環
3. **等待連接** → App 自動發送 'a' 指令開始串流
4. **點擊「開始」** → 開始記錄資料
5. **觀察波形** → 12 條彩色波形線即時更新
6. **點擊「匯出 CSV」** → 儲存資料到檔案

## 🎨 波形圖配色

- **MLX0** (0x0C)：藍色系（深藍、中藍、淺藍）
- **MLX1** (0x0D)：紅色系（深紅、中紅、淺紅）
- **MLX2** (0x0E)：綠色系（深綠、中綠、淺綠）
- **MLX3** (0x0F)：橘色系（深橘、中橘、淺橘）

---

**Version**: 1.0.0
