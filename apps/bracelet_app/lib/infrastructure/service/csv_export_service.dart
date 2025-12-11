import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../domain/entity/mlx_sensor_data.dart';

/// CSV 匯出服務
///
/// 匯出格式（參考圖片）：
/// Timestamp,MLX0_X,MLX0_Y,MLX0_Z,MLX1_X,MLX1_Y,MLX1_Z,MLX2_X,MLX2_Y,MLX2_Z,MLX3_X,MLX3_Y,MLX3_Z
class CsvExportService {
  /// 匯出資料到 CSV 檔案
  ///
  /// 回傳檔案路徑
  static Future<String> exportToCsv(List<MlxSensorData> dataList) async {
    if (dataList.isEmpty) {
      throw Exception('沒有資料可以匯出');
    }

    // 取得文件目錄
    final directory = await getApplicationDocumentsDirectory();

    // 產生檔名（使用當前時間）
    final now = DateTime.now();
    final fileName =
        'MLX_${now.year}${_pad(now.month)}${_pad(now.day)}_${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}.csv';
    final filePath = '${directory.path}/$fileName';

    // 建立檔案
    final file = File(filePath);

    // 寫入標頭
    final buffer = StringBuffer();
    buffer.writeln(MlxSensorData.csvHeader());

    // 寫入資料
    for (var data in dataList) {
      buffer.writeln(data.toCsvRow());
    }

    // 儲存檔案
    await file.writeAsString(buffer.toString());

    print('CSV 匯出成功: $filePath');
    return filePath;
  }

  /// 數字補零（例如：1 → 01）
  static String _pad(int number) {
    return number.toString().padLeft(2, '0');
  }
}
