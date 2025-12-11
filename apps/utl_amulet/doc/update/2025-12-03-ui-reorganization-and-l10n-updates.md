# UI 重組與國際化更新

**日期**: 2025-12-03
**版本**: v1.0
**作者**: Development Team

## 概述

本次更新對平安符 App 的使用者介面進行了重大重組，並完善了國際化支援。主要變更包括：

- 移除中間欄位，採用兩欄式佈局
- 將 CSV 記錄與藍牙指令功能整合至右側控制面板
- 新增第三個分頁標籤
- 針對手機螢幕優化 UI 尺寸
- 新增 26 個多語言翻譯鍵值

## 1. UI 佈局重組

### 1.1 變更前後對比

#### 變更前 (3 欄佈局)

```
┌─────────────┬──────────────┬──────────────┐
│             │              │  右側選單     │
│  圖表列表   │  按鈕面板    │  - 藍牙掃描   │
│             │  (綠色按鈕)  │  - 數據列表   │
│             │              │              │
└─────────────┴──────────────┴──────────────┘
```

#### 變更後 (2 欄佈局)

```
┌─────────────┬──────────────┐
│             │  右側選單     │
│             │  - 藍牙掃描   │
│  圖表列表   │  - 數據列表   │
│             │  - 控制面板   │
│             │              │
└─────────────┴──────────────┘
```

### 1.2 主要變更

#### 檔案: `home_screen.dart`

**移除中間欄位**:

```dart
// 變更前: 3 欄佈局
Row(children: <Widget>[
  Expanded(child: amuletLineChartList),
  VerticalDivider(),
  SizedBox(width: controllerWidth, child: amuletButtonsBoard),
  VerticalDivider(),
  SizedBox(width: controllerWidth, child: tabController)
])

// 變更後: 2 欄佈局
Row(children: <Widget>[
  Expanded(child: amuletLineChartList),
  VerticalDivider(),
  SizedBox(width: controllerWidth, child: tabController)
])
```

**新增第三個分頁標籤**:

```dart
final tabItems = [
  {'icon': Icons.bluetooth_searching_rounded, 'label': appLocalizations.tabBluetoothScanner, 'view': bluetoothScannerView},
  {'icon': Icons.list_alt, 'label': appLocalizations.tabDataList, 'view': amuletDashboard},
  {'icon': Icons.settings_input_antenna, 'label': appLocalizations.tabControlPanel, 'view': amuletControlPanel},
];
```

## 2. 新增控制面板 Widget

### 2.1 檔案結構

建立新檔案: `lib/presentation/view/amulet/amulet_control_panel.dart`

### 2.2 功能整合

控制面板整合了兩大功能區塊：

#### A. 數據記錄區塊

- **功能**: 啟動/停止 CSV 數據記錄
- **狀態顯示**: 閒置中 / 正在記錄數據
- **操作**: 開始記錄 / 停止並匯出 CSV

#### B. 藍牙指令區塊

- **功能**: 發送藍牙指令至設備
- **輸入格式**: 0x + 十六進位指令
- **指令列表**: 預設 9 種常用指令及說明
- **狀態顯示**: 上次指令執行結果

### 2.3 程式碼結構

```dart
class AmuletControlPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          _buildDataRecordingSection(context),  // CSV 記錄控制
          Divider(),
          _BluetoothCommandSection(),            // 藍牙指令輸入
        ],
      ),
    );
  }
}
```

## 3. 分頁標籤優化

### 3.1 問題描述

初始實作中，分頁標籤文字在小螢幕上會被截斷，特別是中文較長的標題。

### 3.2 解決方案

採用自訂 Tab Widget 結構：

```dart
final tabBar = TabBar(
  isScrollable: false,
  labelStyle: const TextStyle(fontSize: 9, height: 1.0),
  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
  indicatorPadding: EdgeInsets.zero,
  tabs: tabItems.map((item) {
    return Tab(
      height: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item['icon'] as IconData, size: 18),
          const SizedBox(height: 2),
          Text(
            item['label'] as String,
            style: const TextStyle(fontSize: 9),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }).toList(),
);
```

### 3.3 關鍵參數

| 參數         | 數值             | 說明             |
| ------------ | ---------------- | ---------------- |
| Tab height   | 60px             | 固定高度避免變形 |
| Icon size    | 18px             | 圖示大小         |
| Font size    | 9px              | 文字大小         |
| labelPadding | 4px (horizontal) | 標籤左右間距     |
| maxLines     | 1                | 單行顯示         |
| overflow     | ellipsis         | 超出顯示省略號   |

## 4. UI 尺寸優化 (手機適配)

### 4.1 問題分析

原始 UI 元件尺寸過大，在手機螢幕上導致：

- 文字被截斷無法完整顯示
- 需要過度捲動
- 資訊密度過低

### 4.2 尺寸調整對照表

#### 控制面板 (`amulet_control_panel.dart`)

| UI 元件      | 變更前 | 變更後 | 減少比例 |
| ------------ | ------ | ------ | -------- |
| 標題文字     | 16px   | 13px   | -19%     |
| 一般文字     | 14px   | 11px   | -21%     |
| 小型文字     | 12px   | 9-10px | -20%     |
| 圖示         | 20px   | 16px   | -20%     |
| 外層 padding | 16px   | 12px   | -25%     |
| 內層 padding | 12px   | 8px    | -33%     |
| 按鈕 padding | 12px   | 8-10px | -25%     |
| 區塊間距     | 24px   | 16px   | -33%     |

#### 分頁標籤 (`home_screen.dart`)

| UI 元件      | 變更前 | 變更後 | 減少比例 |
| ------------ | ------ | ------ | -------- |
| Tab 高度     | 自動   | 60px   | 固定     |
| 圖示大小     | 20px   | 18px   | -10%     |
| 文字大小     | 10px   | 9px    | -10%     |
| labelPadding | 8px    | 4px    | -50%     |

### 4.3 其他優化措施

**輸入框優化**:

```dart
TextField(
  decoration: InputDecoration(
    isDense: true,  // 緊湊模式
    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  ),
  style: const TextStyle(fontSize: 11),
)
```

**文字溢出處理**:

```dart
Flexible(
  child: Text(
    text,
    style: TextStyle(fontSize: 11),
    overflow: TextOverflow.ellipsis,
    maxLines: 2,
  ),
)
```

## 5. 國際化 (l10n) 實作

### 5.1 新增翻譯鍵值

本次更新新增 **26 個**翻譯鍵值，支援三種語言：

- 繁體中文 (zh_TW)
- 簡體中文 (zh)
- 英文 (en)

### 5.2 分頁標籤 (3 個鍵值)

| 鍵值                  | 繁體中文 | 簡體中文 | English |
| --------------------- | -------- | -------- | ------- |
| `tabBluetoothScanner` | 藍牙掃描 | 蓝牙扫描 | BT Scan |
| `tabDataList`         | 數據列表 | 数据列表 | Data    |
| `tabControlPanel`     | 控制面板 | 控制面板 | Control |

### 5.3 數據記錄區塊 (6 個鍵值)

| 鍵值                | 繁體中文                            | 簡體中文                            | English                                  |
| ------------------- | ----------------------------------- | ----------------------------------- | ---------------------------------------- |
| `dataRecording`     | 數據記錄                            | 数据记录                            | Data Recording                           |
| `recording`         | 正在記錄數據...                     | 正在记录数据...                     | Recording...                             |
| `idle`              | 閒置中                              | 闲置中                              | Idle                                     |
| `stopAndExportCSV`  | 停止並匯出 CSV                      | 停止并导出 CSV                      | Stop & Export CSV                        |
| `startRecording`    | 開始記錄數據                        | 开始记录数据                        | Start Recording                          |
| `stopRecordingHint` | 提示：停止記錄後將自動匯出 CSV 檔案 | 提示：停止记录后将自动导出 CSV 文件 | Tip: CSV will auto-export after stopping |

### 5.4 藍牙指令區塊 (17 個鍵值)

#### 基本操作 (8 個)

| 鍵值                 | 繁體中文                 | 簡體中文                 | English                    |
| -------------------- | ------------------------ | ------------------------ | -------------------------- |
| `bluetoothCommand`   | 藍牙指令                 | 蓝牙指令                 | BT Command                 |
| `enterCommand`       | 輸入指令...              | 输入指令...              | Enter command...           |
| `sendCommand`        | 發送指令                 | 发送指令                 | Send                       |
| `pleaseEnterCommand` | 請輸入指令               | 请输入指令               | Please enter command       |
| `commandSent`        | 指令已發送: 0x{command}  | 指令已发送: 0x{command}  | Command sent: 0x{command}  |
| `sendFailed`         | 發送失敗                 | 发送失败                 | Send failed                |
| `errorOccurred`      | 錯誤: {error}            | 错误: {error}            | Error: {error}             |
| `lastCommandSuccess` | 上次: 0x{command} (成功) | 上次: 0x{command} (成功) | Last: 0x{command} (OK)     |
| `lastCommandFailed`  | 上次: 0x{command} (失敗) | 上次: 0x{command} (失败) | Last: 0x{command} (Failed) |

#### 指令說明 (9 個)

| 鍵值                  | 繁體中文             | 簡體中文             | English                 |
| --------------------- | -------------------- | -------------------- | ----------------------- |
| `commandDescription`  | 指令說明             | 指令说明             | Commands                |
| `commandExample`      | 範例: 70D612D90003C5 | 范例: 70D612D90003C5 | Example: 70D612D90003C5 |
| `commandBLEMode`      | BLE 模式             | BLE 模式             | BLE Mode                |
| `commandSetParam`     | 設定參數             | 设定参数             | Set Param               |
| `commandCalibrate`    | 校正                 | 校正                 | Calibrate               |
| `commandMagnetometer` | 磁力計               | 磁力计               | Magnetometer            |
| `commandLowHeadMode`  | 低頭模式             | 低头模式             | Low Head Mode           |
| `commandBreathMode`   | 呼吸模式             | 呼吸模式             | Breath Mode             |
| `commandBindBand`     | 綁定手環             | 绑定手环             | Bind Band               |
| `commandUnbindBand`   | 取消綁定             | 取消绑定             | Unbind Band             |

### 5.5 參數化翻譯

部分翻譯鍵值使用參數化設計，支援動態內容：

```json
"commandSent": "指令已發送: 0x{command}",
"@commandSent": {
  "placeholders": {
    "command": {
      "type": "String"
    }
  }
}
```

使用範例：

```dart
appLocalizations.commandSent(command)  // 輸出: "指令已發送: 0x70"
```

### 5.6 l10n 工作流程

1. **手動編輯 ARB 檔案**:

   - `l10n/app_en.arb`
   - `l10n/app_zh.arb`
   - `l10n/app_zh_tw.arb`

2. **執行程式碼生成**:

   ```bash
   flutter gen-l10n
   ```

3. **自動生成的檔案** (不需手動編輯):

   - `lib/l10n/gen_l10n/app_localizations.dart`
   - `lib/l10n/gen_l10n/app_localizations_en.dart`
   - `lib/l10n/gen_l10n/app_localizations_zh.dart`
   - `lib/l10n/gen_l10n/app_localizations_zh_tw.dart`

4. **在程式中使用**:

   ```dart
   final appLocalizations = AppLocalizations.of(context)!;
   Text(appLocalizations.tabControlPanel)
   ```

## 6. 檔案變更清單

### 6.1 新增檔案

```
lib/presentation/view/amulet/
└── amulet_control_panel.dart          (新增 391 行)
```

### 6.2 修改檔案

```
lib/presentation/screen/
└── home_screen.dart                    (修改 ~30 行)

l10n/
├── app_en.arb                          (新增 26 個鍵值)
├── app_zh.arb                          (新增 26 個鍵值)
└── app_zh_tw.arb                       (新增 26 個鍵值)
```

### 6.3 自動生成檔案

```
lib/l10n/gen_l10n/
├── app_localizations.dart              (自動更新)
├── app_localizations_en.dart           (自動更新)
├── app_localizations_zh.dart           (自動更新)
└── app_localizations_zh_tw.dart        (自動更新)
```

## 7. 測試建議

### 7.1 功能測試

- [ ] CSV 記錄功能正常啟動/停止
- [ ] CSV 檔案正確匯出
- [ ] 藍牙指令正確發送
- [ ] 指令狀態正確顯示
- [ ] 所有 9 種預設指令說明顯示正確

### 7.2 UI 測試

- [ ] 在不同螢幕尺寸下測試 (手機、平板)
- [ ] 橫向模式下 UI 正常顯示
- [ ] 分頁標籤文字完整顯示無截斷
- [ ] 控制面板捲動流暢
- [ ] 所有文字可讀性良好

### 7.3 國際化測試

- [ ] 切換至英文，所有文字正確顯示
- [ ] 切換至簡體中文，所有文字正確顯示
- [ ] 切換至繁體中文，所有文字正確顯示
- [ ] 參數化翻譯功能正常 (如指令發送通知)

### 7.4 效能測試

- [ ] 分頁切換流暢無延遲
- [ ] 控制面板開啟速度正常
- [ ] 藍牙指令發送響應及時
- [ ] UI 動畫流暢 (60fps)

## 8. 已知限制

1. **英文標籤縮寫**: 為了適應小螢幕，英文標籤使用縮寫 (如 "BT Scan")，可能影響初次使用者理解
2. **指令輸入驗證**: 目前未對使用者輸入的十六進位指令進行格式驗證
3. **藍牙連接狀態**: 未檢查藍牙連接狀態即允許發送指令

## 9. 未來改進建議

1. **指令歷史記錄**: 儲存最近發送的指令，方便快速重複使用
2. **指令模板**: 提供可點選的常用指令按鈕，避免手動輸入
3. **輸入驗證**: 加入十六進位格式驗證，防止錯誤指令
4. **連接狀態檢查**: 在發送指令前確認藍牙連接狀態
5. **錯誤提示優化**: 提供更詳細的錯誤訊息和解決建議
6. **長按選單**: 分頁標籤長按顯示完整標題提示

## 10. 參考資源

- Flutter Internationalization: https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
- Material Design Tabs: https://m3.material.io/components/tabs
- Flutter ARB Format: https://github.com/googlei18n/app-resource-bundle/wiki/ApplicationResourceBundleSpecification

---

**文件版本**: 1.0
**最後更新**: 2025-12-03
