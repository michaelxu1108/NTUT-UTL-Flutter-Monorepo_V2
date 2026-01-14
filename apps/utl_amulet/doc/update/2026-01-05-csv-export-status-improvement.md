# 改善 CSV 匯出狀態顯示與完成通知

**日期**: 2026-01-05
**問題**: 用戶反映錄完數據後，狀態直接回到「閒置中」，但實際上還在製作 CSV，導致不知道處理進度

---

## 🔍 問題分析

### 原始問題

根據用戶反映的 PDF 文件描述：

1. **狀態更新不即時**
   - 錄完數據後，數據記錄狀態會直接回到「閒置中」
   - 但可能還在製作 CSV 或裝置還在下載

2. **缺少中間狀態**
   - 沒有「製作 CSV 中」的狀態顯示
   - 用戶不知道系統正在處理

3. **完成提示不明顯**
   - 「下載 CSV 完成」Toast 提示一閃就消失
   - 有時沒注意就會不知道錄製檔到底處理好了沒

---

## ✅ 解決方案

### 1. 新增狀態枚舉

**新增檔案**: `lib/domain/entity/recording_status.dart`

定義了 4 種狀態：

```dart
enum RecordingStatus {
  /// 閒置中 - 未在錄製
  idle,

  /// 錄製中 - 正在記錄數據
  recording,

  /// 製作 CSV 中 - 正在生成 CSV 檔案
  processingCsv,

  /// 下載完成 - CSV 已完成並儲存
  completed,
}
```

**狀態轉換流程**:
```
閒置中 (idle)
    ↓ [按下開始按鈕]
錄製中 (recording)
    ↓ [按下停止按鈕]
製作 CSV 中 (processingCsv)
    ↓ [CSV 生成完成]
下載完成 (completed)
    ↓ [按下開始按鈕進行下一次錄製]
閒置中 (idle)
```

### 2. 擴展 AmuletEntityCreator

**修改檔案**: `lib/application/amulet_entity_creator.dart`

新增方法：
- `recordingStatus` - 取得當前狀態
- `recordingStatusStream` - 狀態變化串流
- `setProcessingCsv()` - 設為「製作 CSV 中」
- `setCompleted()` - 設為「下載完成」
- `reset()` - 重置為「閒置中」

```dart
abstract class AmuletEntityCreator {
  RecordingStatus get recordingStatus;
  Stream<RecordingStatus> get recordingStatusStream;
  void setProcessingCsv();
  void setCompleted();
  void reset();
  // ... 其他方法
}
```

### 3. 更新 ChangeNotifier

**修改檔案**: `lib/presentation/change_notifier/amulet/amulet_features_change_notifier.dart`

新增：
- 監聽狀態變化串流
- 提供狀態更新方法給 UI 層

```dart
class AmuletFeaturesChangeNotifier extends ChangeNotifier {
  RecordingStatus get recordingStatus => amuletEntityCreator.recordingStatus;

  void setProcessingCsv() {
    amuletEntityCreator.setProcessingCsv();
  }

  void setCompleted() {
    amuletEntityCreator.setCompleted();
  }

  void reset() {
    amuletEntityCreator.reset();
  }
}
```

### 4. 改進 UI 顯示

**修改檔案**: `lib/presentation/view/amulet/amulet_control_panel.dart`

#### a. 狀態顏色與圖示

| 狀態 | 顏色 | 圖示 | 說明 |
|------|------|------|------|
| **閒置中** | 灰色 | ⭕ | 可以開始錄製 |
| **錄製中** | 綠色 | 🔴 | 正在記錄數據 |
| **製作 CSV 中** | 橙色 | ⏳ + 轉圈動畫 | 正在生成 CSV |
| **下載完成** | 藍色 | ✅ | CSV 已儲存 |

#### b. 狀態區塊背景色

根據不同狀態顯示不同的背景顏色和邊框：

```dart
Container(
  decoration: BoxDecoration(
    color: _getStatusBackgroundColor(recordingStatus),  // 動態背景色
    border: Border.all(
      color: _getStatusBorderColor(recordingStatus),    // 動態邊框色
    ),
  ),
  child: Row(
    children: [
      // 製作 CSV 中顯示轉圈動畫
      if (recordingStatus == RecordingStatus.processingCsv)
        CircularProgressIndicator(...)
      else
        Icon(_getStatusIcon(recordingStatus)),
      Text(statusText),
    ],
  ),
)
```

#### c. 按鈕邏輯

根據狀態決定按鈕行為：

| 狀態 | 按鈕文字 | 按鈕行為 | 是否可點擊 |
|------|---------|---------|-----------|
| **閒置中** | 開始記錄數據 | 開始錄製 | ✅ |
| **錄製中** | 停止記錄並匯出 CSV | 停止並製作 CSV | ✅ |
| **製作 CSV 中** | 處理中... | - | ❌ 禁用 |
| **下載完成** | 開始記錄數據 | 重置並開始新錄製 | ✅ |

#### d. 狀態提示文字

```dart
if (recordingStatus == RecordingStatus.completed) {
  Text(
    '✅ CSV 檔案已成功儲存！點擊開始按鈕進行下一次錄製',
    style: TextStyle(color: Colors.blue),
  );
}
```

### 5. 改善完成通知

**從 Toast 改為對話框**

修正前（Toast）：
```dart
await Fluttertoast.showToast(
  msg: '下載 CSV 完成',
);
// ❌ 一閃就消失，容易錯過
```

修正後（AwesomeDialog）：
```dart
void _showCompletionDialog(BuildContext context, AppLocalizations appLocalizations) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.success,
    animType: AnimType.scale,
    title: '下載 CSV 完成',
    desc: 'CSV 檔案已成功儲存到您的裝置中！\n\n您可以繼續進行下一次錄製。',
    btnOkText: '確定',
    btnOkOnPress: () { },
    dismissOnTouchOutside: true,
    btnOkColor: Colors.green,
  ).show();
}
// ✅ 明顯的對話框，不會自動消失
```

---

## 📋 修正前後對比

### 修正前 ❌

1. **狀態顯示**:
   ```
   錄製中 → (按停止) → 閒置中
                          ↑ 但實際上還在製作 CSV！
   ```

2. **用戶體驗**:
   - ❌ 看到「閒置中」以為已經完成
   - ❌ Toast 提示一閃就消失
   - ❌ 不知道 CSV 是否真的處理好了

3. **問題**:
   - 狀態與實際不符
   - 容易錯過完成提示
   - 用戶困惑

### 修正後 ✅

1. **狀態顯示**:
   ```
   錄製中 → (按停止) → 製作 CSV 中 → 下載完成 → 閒置中
            ⬇️             ⬇️               ⬇️
         停止錄製       轉圈動畫        成功對話框
   ```

2. **用戶體驗**:
   - ✅ 清楚知道當前處理進度
   - ✅ 「製作 CSV 中」顯示轉圈動畫
   - ✅ 完成時彈出明顯的對話框
   - ✅ 「下載完成」狀態持續顯示

3. **改善**:
   - 狀態與實際完全同步
   - 視覺回饋清晰
   - 不會錯過完成通知

---

## 🎨 UI 效果展示

### 狀態 1：閒置中
```
┌─────────────────────────┐
│ 💾 數據記錄              │
│ ┌─────────────────────┐ │
│ │ ⭕ 閒置中           │ │  ← 灰色背景
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │ ▶ 開始記錄數據      │ │  ← 綠色按鈕
│ └─────────────────────┘ │
└─────────────────────────┘
```

### 狀態 2：錄製中
```
┌─────────────────────────┐
│ 💾 數據記錄              │
│ ┌─────────────────────┐ │
│ │ 🔴 錄製中           │ │  ← 綠色背景
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │ ■ 停止記錄並匯出CSV │ │  ← 紅色按鈕
│ └─────────────────────┘ │
│ 提示：點擊停止按鈕...    │
└─────────────────────────┘
```

### 狀態 3：製作 CSV 中 ⭐ NEW!
```
┌─────────────────────────┐
│ 💾 數據記錄              │
│ ┌─────────────────────┐ │
│ │ ⏳ 製作 CSV 中      │ │  ← 橙色背景 + 轉圈
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │ 處理中...     (禁用)│ │  ← 灰色按鈕（禁用）
│ └─────────────────────┘ │
└─────────────────────────┘
```

### 狀態 4：下載完成 ⭐ NEW!
```
┌─────────────────────────┐
│ 💾 數據記錄              │
│ ┌─────────────────────┐ │
│ │ ✅ 下載完成         │ │  ← 藍色背景
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │ ▶ 開始記錄數據      │ │  ← 綠色按鈕
│ └─────────────────────┘ │
│ ✅ CSV 檔案已成功儲存！  │
│ 點擊開始按鈕進行下一次... │
└─────────────────────────┘

並且彈出成功對話框：

┌──────────────────────────┐
│  ✅ 下載 CSV 完成          │
│                          │
│  CSV 檔案已成功儲存       │
│  到您的裝置中！           │
│                          │
│  您可以繼續進行下一次     │
│  錄製。                   │
│                          │
│        [ 確定 ]          │
└──────────────────────────┘
```

---

## 🔧 技術實現細節

### 狀態管理流程

```dart
// 按下停止按鈕時的完整流程
onPressed: () async {
  // 1. 停止錄製
  features.toggleIsSaving();  // isCreating = false
  lineChartManager.clear();

  // 2. 設為「製作 CSV 中」- 用戶看到橙色狀態和轉圈
  features.setProcessingCsv();

  // 3. 生成 CSV（可能需要時間）
  await fileHandler.downloadAmuletEntitiesFile(...);
  await repository.clear();

  // 4. 設為「下載完成」- 用戶看到藍色狀態
  features.setCompleted();

  // 5. 顯示完成對話框
  _showCompletionDialog(context, appLocalizations);
}
```

### Stream 流程

```
User Action
    ↓
AmuletEntityCreator.setProcessingCsv()
    ↓
_statusController.add(RecordingStatus.processingCsv)
    ↓
recordingStatusStream
    ↓
AmuletFeaturesChangeNotifier (監聽)
    ↓
notifyListeners()
    ↓
UI 重建 (根據新狀態更新)
    ↓
顯示橙色「製作 CSV 中」+ 轉圈動畫
```

---

## 📁 修改檔案清單

### 新增檔案
1. ✅ `lib/domain/entity/recording_status.dart`
   - 定義 4 種錄製狀態
   - 提供狀態判斷的擴展方法

### 修改檔案
2. ✅ `lib/application/amulet_entity_creator.dart`
   - 新增狀態管理功能
   - 新增狀態更新方法

3. ✅ `lib/presentation/change_notifier/amulet/amulet_features_change_notifier.dart`
   - 監聽狀態變化
   - 提供狀態更新接口

4. ✅ `lib/presentation/view/amulet/amulet_control_panel.dart`
   - 根據狀態顯示不同顏色和圖示
   - 實現狀態轉換邏輯
   - 新增完成對話框

---

## ✅ 測試驗證

### 測試場景

#### 場景 1：正常錄製流程
1. **初始狀態**：閒置中（灰色）
2. **點擊開始**：切換為錄製中（綠色）
3. **點擊停止**：
   - 立即切換為製作 CSV 中（橙色 + 轉圈）
   - 按鈕變為「處理中...」並禁用
4. **CSV 生成完成**：
   - 切換為下載完成（藍色 + ✅）
   - 彈出成功對話框
   - 按鈕恢復為「開始記錄數據」
5. **點擊確定**：保持下載完成狀態
6. **點擊開始**：重置為閒置中，然後開始錄製

#### 場景 2：處理中無法操作
1. 錄製中點擊停止
2. 狀態切換為「製作 CSV 中」
3. ✅ **驗證**：按鈕禁用，無法點擊
4. 等待 CSV 生成完成
5. 狀態自動切換為「下載完成」

#### 場景 3：完成後的提示
1. CSV 生成完成
2. ✅ **驗證**：彈出對話框
3. ✅ **驗證**：狀態顯示「下載完成」
4. ✅ **驗證**：狀態區塊下方顯示提示文字
5. 點擊對話框「確定」
6. ✅ **驗證**：對話框關閉，但狀態仍為「下載完成」

---

## 🎯 用戶體驗改善

### 改善點 1：狀態清晰可見
- ✅ **之前**：「閒置中」但實際還在處理
- ✅ **現在**：「製作 CSV 中」+ 轉圈動畫

### 改善點 2：進度反饋明確
- ✅ **之前**：不知道是否在處理
- ✅ **現在**：轉圈動畫 + 按鈕禁用

### 改善點 3：完成通知持久
- ✅ **之前**：Toast 一閃就消失
- ✅ **現在**：對話框 + 持續的「下載完成」狀態

### 改善點 4：視覺回饋豐富
- ✅ 4 種顏色對應 4 種狀態
- ✅ 不同圖示表示不同含義
- ✅ 製作 CSV 時有轉圈動畫
- ✅ 完成時有對話框和勾選圖示

---

## 📝 備註

### 設計決策

1. **為什麼選擇 4 種狀態？**
   - `idle` - 讓用戶知道可以開始
   - `recording` - 讓用戶知道正在錄製
   - `processingCsv` - **解決原問題**：讓用戶知道還在處理
   - `completed` - **解決原問題**：持久顯示完成狀態

2. **為什麼使用對話框而非 Toast？**
   - Toast 自動消失，用戶容易錯過
   - 對話框需要用戶確認，確保看到
   - 對話框可以顯示更多資訊

3. **為什麼在「下載完成」狀態保留「開始記錄數據」按鈕？**
   - 讓用戶可以快速開始下一次錄製
   - 點擊時會自動重置狀態

---

## 🚀 未來可能的改進

1. **顯示 CSV 檔案路徑**
   - 在完成對話框中顯示檔案儲存位置
   - 提供「開啟資料夾」按鈕

2. **錄製統計資訊**
   - 顯示已錄製的數據筆數
   - 顯示錄製時長

3. **進度百分比**
   - 製作 CSV 時顯示進度百分比
   - 需要修改 FileHandler 支援進度回調

---

**修正完成日期**: 2026-01-05
**測試狀態**: ⏳ 待測試
**建議**: 使用 Mock 模式測試完整流程
