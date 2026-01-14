import 'package:hive/hive.dart';
import '../../domain/entity/mlx_sensor_data.dart';
import '../../domain/entity/mlx_sensor_data_adapter.dart';

/// 感測器資料儲存庫
///
/// 使用 Hive 資料庫儲存所有感測器資料，支援 24 小時以上的長時間記錄
class SensorDataRepository {
  static const String _boxName = 'sensor_data';
  Box<MlxSensorData>? _box;

  /// 取得資料庫檔案路徑
  String? get databasePath => _box?.path;

  /// 初始化資料庫
  ///
  /// 必須在使用前呼叫此方法
  Future<void> init() async {
    // 註冊 TypeAdapter（只需註冊一次）
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MlxSensorDataAdapter());
    }

    // 開啟 Box
    _box = await Hive.openBox<MlxSensorData>(_boxName);
  }

  /// 新增資料
  Future<void> add(MlxSensorData data) async {
    await _box?.add(data);
  }

  /// 批次新增資料（提升效能）
  Future<void> addAll(List<MlxSensorData> dataList) async {
    await _box?.addAll(dataList);
  }

  /// 取得所有資料
  List<MlxSensorData> getAll() {
    return _box?.values.toList() ?? [];
  }

  /// 取得資料筆數
  int get count => _box?.length ?? 0;

  /// 取得最新的 N 筆資料
  List<MlxSensorData> getLatest(int n) {
    final allData = getAll();
    if (allData.length <= n) {
      return allData;
    }
    return allData.sublist(allData.length - n);
  }

  /// 清除所有資料
  Future<void> clear() async {
    await _box?.clear();
  }

  /// 關閉資料庫
  Future<void> close() async {
    await _box?.close();
  }

  /// 刪除資料庫（徹底移除所有資料）
  Future<void> delete() async {
    await _box?.clear();
    await _box?.close();
    await Hive.deleteBoxFromDisk(_boxName);
  }

  /// 取得資料庫檔案大小（MB）
  double get sizeInMB {
    if (_box == null) return 0;
    // 估算：每筆資料約 80 bytes
    final bytes = count * 80;
    return bytes / (1024 * 1024);
  }

  /// 是否已初始化
  bool get isInitialized => _box != null && _box!.isOpen;
}
