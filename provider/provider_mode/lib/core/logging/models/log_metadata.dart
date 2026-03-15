// lib/core/logging/models/log_metadata.dart

import 'dart:io';

/// 日志元数据模型
/// 包含设备信息、应用版本、网络状态等上下文信息
class LogMetadata {
  /// 应用版本号
  final String appVersion;

  /// 构建号
  final String buildNumber;

  /// 设备型号（如：iPhone 14 Pro, Samsung Galaxy S23）
  final String deviceModel;

  /// 设备制造商
  final String? deviceManufacturer;

  /// 操作系统版本
  final String osVersion;

  /// 平台名称（Android/iOS/macOS/Windows/Linux）
  final String platform;

  /// 网络类型（WiFi/Cellular/Ethernet/None/Unknown）
  final String? networkType;

  /// 是否连接网络
  final bool? isConnected;

  /// 屏幕分辨率
  final String? screenResolution;

  /// 应用内存使用量（MB）
  final int? memoryUsage;

  /// 设备可用存储空间（GB）
  final double? availableStorage;

  /// 电池电量（0-100）
  final int? batteryLevel;

  /// 是否正在充电
  final bool? isCharging;

  /// 是否越狱/Root
  final bool? isJailbroken;

  /// 设备唯一标识
  final String? deviceId;

  /// 时区
  final String? timezone;

  /// 语言设置
  final String? locale;

  const LogMetadata({
    required this.appVersion,
    required this.buildNumber,
    required this.deviceModel,
    this.deviceManufacturer,
    required this.osVersion,
    required this.platform,
    this.networkType,
    this.isConnected,
    this.screenResolution,
    this.memoryUsage,
    this.availableStorage,
    this.batteryLevel,
    this.isCharging,
    this.isJailbroken,
    this.deviceId,
    this.timezone,
    this.locale,
  });

  /// 从JSON创建
  factory LogMetadata.fromJson(Map<String, dynamic> json) {
    return LogMetadata(
      appVersion: json['appVersion'] as String? ?? 'unknown',
      buildNumber: json['buildNumber'] as String? ?? 'unknown',
      deviceModel: json['deviceModel'] as String? ?? 'unknown',
      deviceManufacturer: json['deviceManufacturer'] as String?,
      osVersion: json['osVersion'] as String? ?? 'unknown',
      platform: json['platform'] as String? ?? 'unknown',
      networkType: json['networkType'] as String?,
      isConnected: json['isConnected'] as bool?,
      screenResolution: json['screenResolution'] as String?,
      memoryUsage: json['memoryUsage'] as int?,
      availableStorage: json['availableStorage'] as double?,
      batteryLevel: json['batteryLevel'] as int?,
      isCharging: json['isCharging'] as bool?,
      isJailbroken: json['isJailbroken'] as bool?,
      deviceId: json['deviceId'] as String?,
      timezone: json['timezone'] as String?,
      locale: json['locale'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'appVersion': appVersion,
      'buildNumber': buildNumber,
      'deviceModel': deviceModel,
      'deviceManufacturer': deviceManufacturer,
      'osVersion': osVersion,
      'platform': platform,
      'networkType': networkType,
      'isConnected': isConnected,
      'screenResolution': screenResolution,
      'memoryUsage': memoryUsage,
      'availableStorage': availableStorage,
      'batteryLevel': batteryLevel,
      'isCharging': isCharging,
      'isJailbroken': isJailbroken,
      'deviceId': deviceId,
      'timezone': timezone,
      'locale': locale,
    };
  }

  /// 创建空元数据
  static LogMetadata empty() {
    return LogMetadata(
      appVersion: 'unknown',
      buildNumber: 'unknown',
      deviceModel: 'unknown',
      osVersion: 'unknown',
      platform: Platform.operatingSystem,
    );
  }

  /// 复制并修改
  LogMetadata copyWith({
    String? appVersion,
    String? buildNumber,
    String? deviceModel,
    String? deviceManufacturer,
    String? osVersion,
    String? platform,
    String? networkType,
    bool? isConnected,
    String? screenResolution,
    int? memoryUsage,
    double? availableStorage,
    int? batteryLevel,
    bool? isCharging,
    bool? isJailbroken,
    String? deviceId,
    String? timezone,
    String? locale,
  }) {
    return LogMetadata(
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceManufacturer: deviceManufacturer ?? this.deviceManufacturer,
      osVersion: osVersion ?? this.osVersion,
      platform: platform ?? this.platform,
      networkType: networkType ?? this.networkType,
      isConnected: isConnected ?? this.isConnected,
      screenResolution: screenResolution ?? this.screenResolution,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      availableStorage: availableStorage ?? this.availableStorage,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isCharging: isCharging ?? this.isCharging,
      isJailbroken: isJailbroken ?? this.isJailbroken,
      deviceId: deviceId ?? this.deviceId,
      timezone: timezone ?? this.timezone,
      locale: locale ?? this.locale,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('=== 设备信息 ===');
    buffer.writeln('应用版本: $appVersion ($buildNumber)');
    buffer.writeln('设备型号: $deviceModel');
    if (deviceManufacturer != null) {
      buffer.writeln('制造商: $deviceManufacturer');
    }
    buffer.writeln('系统版本: $osVersion');
    buffer.writeln('平台: $platform');
    if (networkType != null) {
      buffer.writeln('网络类型: $networkType');
    }
    if (isConnected != null) {
      buffer.writeln('网络连接: ${isConnected! ? "已连接" : "未连接"}');
    }
    if (screenResolution != null) {
      buffer.writeln('屏幕分辨率: $screenResolution');
    }
    if (memoryUsage != null) {
      buffer.writeln('内存使用: ${memoryUsage}MB');
    }
    if (availableStorage != null) {
      buffer.writeln('可用存储: ${availableStorage!.toStringAsFixed(2)}GB');
    }
    if (batteryLevel != null) {
      buffer.writeln('电池电量: $batteryLevel%');
    }
    if (isCharging != null) {
      buffer.writeln('充电状态: ${isCharging! ? "充电中" : "未充电"}');
    }
    if (isJailbroken != null && isJailbroken!) {
      buffer.writeln('⚠️ 设备已越狱/Root');
    }
    if (timezone != null) {
      buffer.writeln('时区: $timezone');
    }
    if (locale != null) {
      buffer.writeln('语言: $locale');
    }
    return buffer.toString();
  }
}
