import 'package:freezed_annotation/freezed_annotation.dart';

part 'error_log_entry.freezed.dart';
part 'error_log_entry.g.dart';

/// 错误分类枚举
enum ErrorCategory {
  /// Flutter 框架错误
  @JsonValue('flutter')
  flutter,

  /// 平台通道错误
  @JsonValue('platform')
  platform,

  /// 网络请求错误
  @JsonValue('network')
  network,

  /// 本地存储错误
  @JsonValue('storage')
  storage,

  /// 业务逻辑错误
  @JsonValue('business')
  business,

  /// 未捕获异常
  @JsonValue('uncaught')
  uncaught,
}

/// 错误日志条目
@freezed
sealed class ErrorLogEntry with _$ErrorLogEntry {
  const factory ErrorLogEntry({
    /// 唯一标识符 (UUID)
    required String id,

    /// 错误发生时间
    required DateTime timestamp,

    /// 错误分类
    required ErrorCategory category,

    /// 错误消息
    required String message,

    /// 堆栈跟踪
    required String stackTrace,

    /// 设备信息
    required DeviceInfo deviceInfo,

    /// 上下文信息（如页面名称、操作描述等）
    String? context,

    /// 附加数据（可存储额外的错误相关信息）
    Map<String, dynamic>? additionalData,
  }) = _ErrorLogEntry;

  factory ErrorLogEntry.fromJson(Map<String, dynamic> json) =>
      _$ErrorLogEntryFromJson(json);
}

/// 设备信息
@freezed
sealed class DeviceInfo with _$DeviceInfo {
  const factory DeviceInfo({
    /// 平台类型 (android/ios/windows/macos/linux/web)
    required String platform,

    /// 操作系统版本
    required String osVersion,

    /// 设备型号
    required String deviceModel,

    /// 应用版本
    required String appVersion,

    /// 构建号
    required String buildNumber,

    /// 设备唯一标识符
    String? deviceId,

    /// 设备品牌 (仅Android)
    String? brand,

    /// 设备制造商 (仅Android)
    String? manufacturer,

    /// 系统语言
    String? language,

    /// 屏幕分辨率
    String? screenResolution,

    /// 是否为物理设备
    bool? isPhysicalDevice,
  }) = _DeviceInfo;

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);
}
