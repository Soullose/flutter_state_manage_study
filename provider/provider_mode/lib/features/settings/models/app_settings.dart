import 'package:equatable/equatable.dart';

/// 应用设置数据模型
///
/// 包含应用的各种设置选项，使用Equatable方便比较和测试
class AppSettings extends Equatable {
  /// 是否启用通知
  final bool notificationsEnabled;

  /// 是否启用声音
  final bool soundEnabled;

  /// 是否启用振动
  final bool vibrationEnabled;

  /// 是否启用自动更新检查
  final bool autoUpdateCheck;

  /// 是否启用数据统计
  final bool analyticsEnabled;

  /// 缓存大小（MB）
  final int cacheSizeMB;

  const AppSettings({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = false,
    this.autoUpdateCheck = true,
    this.analyticsEnabled = false,
    this.cacheSizeMB = 0,
  });

  /// 创建副本
  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? autoUpdateCheck,
    bool? analyticsEnabled,
    int? cacheSizeMB,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      autoUpdateCheck: autoUpdateCheck ?? this.autoUpdateCheck,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      cacheSizeMB: cacheSizeMB ?? this.cacheSizeMB,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'notifications_enabled': notificationsEnabled,
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
      'auto_update_check': autoUpdateCheck,
      'analytics_enabled': analyticsEnabled,
      'cache_size_mb': cacheSizeMB,
    };
  }

  /// 从Map创建
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      notificationsEnabled: map['notifications_enabled'] ?? true,
      soundEnabled: map['sound_enabled'] ?? true,
      vibrationEnabled: map['vibration_enabled'] ?? false,
      autoUpdateCheck: map['auto_update_check'] ?? true,
      analyticsEnabled: map['analytics_enabled'] ?? false,
      cacheSizeMB: map['cache_size_mb'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        notificationsEnabled,
        soundEnabled,
        vibrationEnabled,
        autoUpdateCheck,
        analyticsEnabled,
        cacheSizeMB,
      ];
}
