import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/error_log_entry.dart';
import '../utils/device_info_collector.dart';

/// 错误上报策略抽象
abstract class ErrorReportStrategy {
  Future<void> report(ErrorLogEntry entry);
}

/// 仅本地存储策略
class LocalOnlyStrategy implements ErrorReportStrategy {
  @override
  Future<void> report(ErrorLogEntry entry) async {
    // 仅本地存储，不做远程上报
  }
}

/// 错误日志存储服务
class ErrorLogStorageService {
  static final ErrorLogStorageService _instance =
      ErrorLogStorageService._internal();
  factory ErrorLogStorageService() => _instance;
  ErrorLogStorageService._internal();

  final Uuid _uuid = const Uuid();
  final DeviceInfoCollector _deviceInfoCollector = DeviceInfoCollector();
  ErrorReportStrategy _reportStrategy = LocalOnlyStrategy();

  /// 日志目录名称
  static const String _logDirName = 'error_logs';

  /// 日志文件前缀
  static const String _logFilePrefix = 'error_log_';

  /// 日志文件扩展名
  static const String _logFileExtension = '.json';

  /// 设置错误上报策略
  void setReportStrategy(ErrorReportStrategy strategy) {
    _reportStrategy = strategy;
  }

  /// 获取日志目录路径
  Future<String> get _logDirectoryPath async {
    final appDir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${appDir.path}/$_logDirName');
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }
    return logDir.path;
  }

  /// 获取当天的日志文件路径
  Future<File> _getTodayLogFile() async {
    final logDir = await _logDirectoryPath;
    final today = _getDateString(DateTime.now());
    return File('$logDir/$_logFilePrefix$today$_logFileExtension');
  }

  /// 获取日期字符串 (yyyy-MM-dd)
  String _getDateString(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// 记录错误日志
  Future<ErrorLogEntry> logError({
    required Object error,
    StackTrace? stackTrace,
    ErrorCategory category = ErrorCategory.uncaught,
    String? context,
    Map<String, dynamic>? additionalData,
  }) async {
    final entry = ErrorLogEntry(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      category: category,
      message: error.toString(),
      stackTrace: stackTrace?.toString() ?? '',
      deviceInfo: await _deviceInfoCollector.collect(),
      context: context,
      additionalData: additionalData,
    );

    // Debug 模式下打印到控制台
    if (kDebugMode) {
      debugPrint('════════════════════════════════════════════════════');
      debugPrint('🔴 ERROR LOG [${entry.category.name.toUpperCase()}]');
      debugPrint('Time: ${entry.timestamp}');
      debugPrint('Message: ${entry.message}');
      if (entry.context != null) {
        debugPrint('Context: ${entry.context}');
      }
      debugPrint('StackTrace:\n${entry.stackTrace}');
      debugPrint('════════════════════════════════════════════════════');
    }

    // 保存到本地文件
    await _saveEntry(entry);

    // 执行远程上报策略
    await _reportStrategy.report(entry);

    return entry;
  }

  /// 保存日志条目到文件
  Future<void> _saveEntry(ErrorLogEntry entry) async {
    try {
      final file = await _getTodayLogFile();
      List<ErrorLogEntry> entries = [];

      // 读取现有日志
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final json = jsonDecode(content) as Map<String, dynamic>;
          final logs = json['logs'] as List<dynamic>;
          entries = logs
              .map((e) => ErrorLogEntry.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      // 添加新条目
      entries.insert(0, entry);

      // 写入文件
      final json = jsonEncode({
        'logs': entries.map((e) => e.toJson()).toList(),
      });
      await file.writeAsString(json);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save error log: $e');
      }
    }
  }

  /// 获取所有日志
  Future<List<ErrorLogEntry>> getAllLogs() async {
    final List<ErrorLogEntry> allEntries = [];
    final logDir = await _logDirectoryPath;
    final dir = Directory(logDir);

    if (!await dir.exists()) {
      return allEntries;
    }

    final files = await dir
        .list()
        .where(
          (entity) =>
              entity is File &&
              entity.path.endsWith(_logFileExtension) &&
              entity.path.contains(_logFilePrefix),
        )
        .cast<File>()
        .toList();

    // 按文件名排序（最新的在前）
    files.sort((a, b) => b.path.compareTo(a.path));

    for (final file in files) {
      try {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final json = jsonDecode(content) as Map<String, dynamic>;
          final logs = json['logs'] as List<dynamic>;
          final entries = logs
              .map((e) => ErrorLogEntry.fromJson(e as Map<String, dynamic>))
              .toList();
          allEntries.addAll(entries);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to read log file ${file.path}: $e');
        }
      }
    }

    return allEntries;
  }

  /// 获取指定日期的日志
  Future<List<ErrorLogEntry>> getLogsByDate(DateTime date) async {
    final logDir = await _logDirectoryPath;
    final dateString = _getDateString(date);
    final file = File('$logDir/$_logFilePrefix$dateString$_logFileExtension');

    if (!await file.exists()) {
      return [];
    }

    try {
      final content = await file.readAsString();
      if (content.isEmpty) {
        return [];
      }
      final json = jsonDecode(content) as Map<String, dynamic>;
      final logs = json['logs'] as List<dynamic>;
      return logs
          .map((e) => ErrorLogEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to read log file: $e');
      }
      return [];
    }
  }

  /// 删除指定日志
  Future<bool> deleteLog(String id) async {
    final logDir = await _logDirectoryPath;
    final dir = Directory(logDir);

    if (!await dir.exists()) {
      return false;
    }

    final files = await dir
        .list()
        .where(
          (entity) =>
              entity is File &&
              entity.path.endsWith(_logFileExtension) &&
              entity.path.contains(_logFilePrefix),
        )
        .cast<File>()
        .toList();

    for (final file in files) {
      try {
        final content = await file.readAsString();
        if (content.isEmpty) continue;

        final json = jsonDecode(content) as Map<String, dynamic>;
        final logs = json['logs'] as List<dynamic>;
        final entries = logs
            .map((e) => ErrorLogEntry.fromJson(e as Map<String, dynamic>))
            .toList();

        final initialLength = entries.length;
        entries.removeWhere((e) => e.id == id);

        if (entries.length < initialLength) {
          // 找到并删除了条目
          if (entries.isEmpty) {
            // 如果文件为空，删除文件
            await file.delete();
          } else {
            // 更新文件
            final newJson = jsonEncode({
              'logs': entries.map((e) => e.toJson()).toList(),
            });
            await file.writeAsString(newJson);
          }
          return true;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to process log file: $e');
        }
      }
    }

    return false;
  }

  /// 清空所有日志
  Future<void> clearAllLogs() async {
    final logDir = await _logDirectoryPath;
    final dir = Directory(logDir);

    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// 导出所有日志为JSON字符串
  Future<String> exportAsJsonString() async {
    final logs = await getAllLogs();
    final json = jsonEncode({
      'exportTime': DateTime.now().toIso8601String(),
      'totalLogs': logs.length,
      'logs': logs.map((e) => e.toJson()).toList(),
    });
    return json;
  }

  /// 导出日志到文件
  Future<File?> exportToFile() async {
    try {
      final jsonString = await exportAsJsonString();
      final exportDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final exportFile = File(
        '${exportDir.path}/error_log_export_$timestamp.json',
      );
      await exportFile.writeAsString(jsonString);
      return exportFile;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to export logs: $e');
      }
      return null;
    }
  }

  /// 获取日志文件大小（字节）
  Future<int> getTotalLogSize() async {
    final logDir = await _logDirectoryPath;
    final dir = Directory(logDir);

    if (!await dir.exists()) {
      return 0;
    }

    int totalSize = 0;
    final files = await dir
        .list()
        .where(
          (entity) =>
              entity is File &&
              entity.path.endsWith(_logFileExtension) &&
              entity.path.contains(_logFilePrefix),
        )
        .cast<File>()
        .toList();

    for (final file in files) {
      try {
        totalSize += await file.length();
      } catch (e) {
        // 忽略错误
      }
    }

    return totalSize;
  }

  /// 获取日志文件数量
  Future<int> getLogFileCount() async {
    final logDir = await _logDirectoryPath;
    final dir = Directory(logDir);

    if (!await dir.exists()) {
      return 0;
    }

    final files = await dir
        .list()
        .where(
          (entity) =>
              entity is File &&
              entity.path.endsWith(_logFileExtension) &&
              entity.path.contains(_logFilePrefix),
        )
        .toList();

    return files.length;
  }
}
