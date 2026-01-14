import 'package:flutter/material.dart';
import 'mlx_sensor_data.dart';

/// 感測器軸向枚舉
///
/// 定義所有可選的感測器資料項目
enum SensorAxis {
  // ==================== MLX90393 磁力計 ====================
  // MLX0 (拇指)
  mlx0X('MLX0-X', '拇指 X軸', Colors.blue),
  mlx0Y('MLX0-Y', '拇指 Y軸', Colors.lightBlue),
  mlx0Z('MLX0-Z', '拇指 Z軸', Color(0xFF0D47A1)),

  // MLX1 (食指)
  mlx1X('MLX1-X', '食指 X軸', Colors.red),
  mlx1Y('MLX1-Y', '食指 Y軸', Colors.redAccent),
  mlx1Z('MLX1-Z', '食指 Z軸', Color(0xFFB71C1C)),

  // MLX2 (中指)
  mlx2X('MLX2-X', '中指 X軸', Colors.green),
  mlx2Y('MLX2-Y', '中指 Y軸', Colors.lightGreen),
  mlx2Z('MLX2-Z', '中指 Z軸', Color(0xFF1B5E20)),

  // MLX3 (無名指)
  mlx3X('MLX3-X', '無名指 X軸', Colors.orange),
  mlx3Y('MLX3-Y', '無名指 Y軸', Colors.deepOrange),
  mlx3Z('MLX3-Z', '無名指 Z軸', Color(0xFFE65100)),

  // ==================== IMU 加速度計 ====================
  accX('IMU-AccX', '加速度 X軸', Color(0xFF9C27B0)),
  accY('IMU-AccY', '加速度 Y軸', Color(0xFFBA68C8)),
  accZ('IMU-AccZ', '加速度 Z軸', Color(0xFF6A1B9A)),

  // ==================== IMU 陀螺儀 ====================
  gyroX('IMU-GyroX', '陀螺儀 X軸', Color(0xFF00BCD4)),
  gyroY('IMU-GyroY', '陀螺儀 Y軸', Color(0xFF4DD0E1)),
  gyroZ('IMU-GyroZ', '陀螺儀 Z軸', Color(0xFF006064)),

  // ==================== IMU 磁力計 ====================
  magX('IMU-MagX', 'IMU磁力 X軸', Color(0xFFFF5722)),
  magY('IMU-MagY', 'IMU磁力 Y軸', Color(0xFFFF8A65)),
  magZ('IMU-MagZ', 'IMU磁力 Z軸', Color(0xFFBF360C));

  const SensorAxis(this.label, this.description, this.color);

  /// 簡短標籤（用於圖例）
  final String label;

  /// 完整描述（用於勾選列表）
  final String description;

  /// 波形顏色
  final Color color;

  /// 從資料中取得對應的值
  double getValue(MlxSensorData data) {
    switch (this) {
      // MLX0
      case SensorAxis.mlx0X:
        return data.mlx0X.toDouble();
      case SensorAxis.mlx0Y:
        return data.mlx0Y.toDouble();
      case SensorAxis.mlx0Z:
        return data.mlx0Z.toDouble();

      // MLX1
      case SensorAxis.mlx1X:
        return data.mlx1X.toDouble();
      case SensorAxis.mlx1Y:
        return data.mlx1Y.toDouble();
      case SensorAxis.mlx1Z:
        return data.mlx1Z.toDouble();

      // MLX2
      case SensorAxis.mlx2X:
        return data.mlx2X.toDouble();
      case SensorAxis.mlx2Y:
        return data.mlx2Y.toDouble();
      case SensorAxis.mlx2Z:
        return data.mlx2Z.toDouble();

      // MLX3
      case SensorAxis.mlx3X:
        return data.mlx3X.toDouble();
      case SensorAxis.mlx3Y:
        return data.mlx3Y.toDouble();
      case SensorAxis.mlx3Z:
        return data.mlx3Z.toDouble();

      // IMU 加速度
      case SensorAxis.accX:
        return data.accX.toDouble();
      case SensorAxis.accY:
        return data.accY.toDouble();
      case SensorAxis.accZ:
        return data.accZ.toDouble();

      // IMU 陀螺儀
      case SensorAxis.gyroX:
        return data.gyroX.toDouble();
      case SensorAxis.gyroY:
        return data.gyroY.toDouble();
      case SensorAxis.gyroZ:
        return data.gyroZ.toDouble();

      // IMU 磁力計
      case SensorAxis.magX:
        return data.magX.toDouble();
      case SensorAxis.magY:
        return data.magY.toDouble();
      case SensorAxis.magZ:
        return data.magZ.toDouble();
    }
  }

  /// 感測器分類
  SensorCategory get category {
    if (name.startsWith('mlx')) return SensorCategory.mlx;
    if (name.startsWith('acc')) return SensorCategory.accelerometer;
    if (name.startsWith('gyro')) return SensorCategory.gyroscope;
    if (name.startsWith('mag')) return SensorCategory.magnetometer;
    return SensorCategory.mlx;
  }
}

/// 感測器分類
enum SensorCategory {
  mlx('MLX90393 磁力計', Icons.track_changes),
  accelerometer('IMU - 加速度計', Icons.speed),
  gyroscope('IMU - 陀螺儀', Icons.rotate_right),
  magnetometer('IMU - 磁力計', Icons.explore);

  const SensorCategory(this.title, this.icon);

  final String title;
  final IconData icon;

  /// 取得該分類下的所有軸向
  List<SensorAxis> get axes {
    return SensorAxis.values.where((axis) => axis.category == this).toList();
  }
}
