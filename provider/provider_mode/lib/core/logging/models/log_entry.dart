// lib/core/logging/models/log_entry.dart

import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import 'log_metadata.dart';

/// 日志级别枚举
enum LogLevel {
  error,
  warning,
  info,
  debug;

  String get displayName {
    switch (this) {
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.debug:
        return 'DEBUG';
    }
  }

  String get emoji {
    switch (this) {
      case LogLevel.error:
        return '🔴';
      case LogLevel.warning:
        return '🟡';
      case LogLevel.info:
        return '🔵';
      case LogLevel.debug:
        return '⚪';
    }
  }
}

/// 日志条目模型
/// 表示单条日志记录，包含错误信息、堆栈跟踪和元数据
class LogEntry extends Equatable {
  /// 唯一标识符
  final String id;

  /// 时间戳
  final DateTime timestamp;

  /// 日志级别
  final LogLevel level;

  /// 错误/日志消息
  final String message;

  /// 堆栈跟踪（可选）
  final String? stackTrace;

  /// 错误类型/类名（可选）
  final String? errorType;

  /// 错误来源（如：文件名、类名、方法名）
  final String? source;

  /// 附加数据（可选的额外上下文）
  final Map<String, dynamic>? additionalData;

  /// 元数据（设备信息等）
  final LogMetadata? metadata;

  const LogEntry({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.message,
    this.stackTrace,
    this.errorType,
    this.source,
    this.additionalData,
    this.metadata,
  });

  /// 创建新的日志条目（自动生成ID和时间戳）
  factory LogEntry.create({
    required LogLevel level,
    required String message,
    String? stackTrace,
    String? errorType,
    String? source,
    Map<String, dynamic>? additionalData,
    LogMetadata? metadata,
  }) {
    return LogEntry(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      level: level,
      message: message,
      stackTrace: stackTrace,
      errorType: errorType,
      source: source,
      additionalData: additionalData,
      metadata: metadata,
    );
  }

  /// 从JSON创建
  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'] as String? ?? const Uuid().v4(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      level: LogLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => LogLevel.info,
      ),
      message: json['message'] as String? ?? '',
      stackTrace: json['stackTrace'] as String?,
      errorType: json['errorType'] as String?,
      source: json['source'] as String?,
      additionalData: json['additionalData'] != null
          ? Map<String, dynamic>.from(json['additionalData'] as Map)
          : null,
      metadata: json['metadata'] != null
          ? LogMetadata.fromJson(
              Map<String, dynamic>.from(json['metadata'] as Map))
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'message': message,
      'stackTrace': stackTrace,
      'errorType': errorType,
      'source': source,
      'additionalData': additionalData,
      'metadata': metadata?.toJson(),
    };
  }

  /// 获取简短描述（用于列表显示）
  String get shortMessage {
    const maxLength = 100;
    if (message.length <= maxLength) return message;
    return '${message.substring(0, maxLength)}...';
  }

  /// 格式化时间显示
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
    }
  }

  /// 格式化完整时间
  String get formattedFullTime {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }

  /// 转换为可读的字符串格式（用于导出）
  String toReadableString() {
    final buffer = StringBuffer();
    buffer.writeln('========================================');
    buffer.writeln('[$level] ${formattedFullTime}');
    buffer.writeln('ID: $id');
    buffer.writeln('----------------------------------------');
    buffer.writeln('消息: $message');
    if (errorType != null) {
      buffer.writeln('错误类型: $errorType');
    }
    if (source != null) {
      buffer.writeln('来源: $source');
    }
    if (stackTrace != null && stackTrace!.isNotEmpty) {
      buffer.writeln('----------------------------------------');
      buffer.writeln('堆栈跟踪:');
      buffer.writeln(stackTrace);
    }
    if (additionalData != null && additionalData!.isNotEmpty) {
      buffer.writeln('----------------------------------------');
      buffer.writeln('附加数据:');
      additionalData!.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    }
    if (metadata != null) {
      buffer.writeln('----------------------------------------');
      buffer.write(metadata.toString());
    }
    buffer.writeln('========================================');
    return buffer.toString();
  }

  /// 复制并修改
  LogEntry copyWith({
    String? id,
    DateTime? timestamp,
    LogLevel? level,
    String? message,
    String? stackTrace,
    String? errorType,
    String? source,
    Map<String, dynamic>? additionalData,
    LogMetadata? metadata,
  }) {
    return LogEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      level: level ?? this.level,
      message: message ?? this.message,
      stackTrace: stackTrace ?? this.stackTrace,
      errorType: errorType ?? this.errorType,
      source: source ?? this.source,
      additionalData: additionalData ?? this.additionalData,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        timestamp,
        level,
        message,
        stackTrace,
        errorType,
        source,
        additionalData,
        metadata,
      ];
}

/// 日志筛选条件
class LogFilter {
  /// 日志级别筛选
  final LogLevel? level;

  /// 开始日期
  final DateTime? startDate;

  /// 结束日期
  final DateTime? endDate;

  /// 搜索关键词
  final String? keyword;

  /// 错误类型筛选
  final String? errorType;

  const LogFilter({
    this.level,
    this.startDate,
    this.endDate,
    this.keyword,
    this.errorType,
  });

  /// 空筛选条件
  static const LogFilter empty = LogFilter();

  /// 是否为空筛选
  bool get isEmpty =>
      level == null &&
      startDate == null &&
      endDate == null &&
      (keyword == null || keyword!.isEmpty) &&
      (errorType == null || errorType!.isEmpty);

  /// 检查日志是否匹配筛选条件
  bool matches(LogEntry entry) {
    if (level != null && entry.level != level) {
      return false;
    }

    if (startDate != null && entry.timestamp.isBefore(startDate!)) {
      return false;
    }

    if (endDate != null && entry.timestamp.isAfter(endDate!)) {
      return false;
    }

    if (keyword != null && keyword!.isNotEmpty) {
      final lowerKeyword = keyword!.toLowerCase();
      final matchMessage = entry.message.toLowerCase().contains(lowerKeyword);
      final matchStack =
          entry.stackTrace?.toLowerCase().contains(lowerKeyword) ?? false;
      final matchType =
          entry.errorType?.toLowerCase().contains(lowerKeyword) ?? false;
      if (!matchMessage && !matchStack && !matchType) {
        return false;
      }
    }

    if (errorType != null && errorType!.isNotEmpty) {
      if (entry.errorType?.contains(errorType!) != true) {
        return false;
      }
    }

    return true;
  }

  /// 复制并修改
  LogFilter copyWith({
    LogLevel? level,
    DateTime? startDate,
    DateTime? endDate,
    String? keyword,
    String? errorType,
  }) {
    return LogFilter(
      level: level ?? this.level,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      keyword: keyword ?? this.keyword,
      errorType: errorType ?? this.errorType,
    );
  }
}
