// lib/core/logging/log_file_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'models/log_entry.dart';

/// 日志文件管理服务
/// 负责日志文件的创建、读取、写入和删除操作
class LogFileService {
  /// 日志文件目录名称
  static const String _logDirectoryName = 'error_logs';

  /// 日志文件前缀
  static const String _logFilePrefix = 'error_log_';

  /// 日志文件扩展名
  static const String _logFileExtension = '.log';

  /// 导出文件前缀
  static const String _exportFilePrefix = 'logs_export_';

  /// 日期格式化器
  final DateFormat _dateFormat = DateFormat('yyyyMMdd');

  /// 日志目录路径
  String? _logDirectoryPath;

  /// 获取日志目录路径
  Future<String> getLogDirectory() async {
    if (_logDirectoryPath != null) {
      return _logDirectoryPath!;
    }

    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory logDir = Directory('${appDir.path}/$_logDirectoryName');

    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    _logDirectoryPath = logDir.path;
    return _logDirectoryPath!;
  }

  /// 获取今日日志文件路径
  Future<String> getTodayLogFilePath() async {
    final logDir = await getLogDirectory();
    final today = _dateFormat.format(DateTime.now());
    return '$logDir/$_logFilePrefix$today$_logFileExtension';
  }

  /// 获取指定日期的日志文件路径
  Future<String> getLogFilePath(DateTime date) async {
    final logDir = await getLogDirectory();
    final dateStr = _dateFormat.format(date);
    return '$logDir/$_logFilePrefix$dateStr$_logFileExtension';
  }

  /// 写入日志条目到文件
  Future<void> writeLogEntry(LogEntry entry) async {
    try {
      final filePath = await getLogFilePath(entry.timestamp);
      final file = File(filePath);

      // 确保文件所在目录存在
      final dir = file.parent;
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // 将日志条目转换为JSON并追加到文件
      final jsonLine = '${jsonEncode(entry.toJson())}\n';
      await file.writeAsString(
        jsonLine,
        mode: FileMode.append,
        flush: true,
      );
    } catch (e) {
      // 写入失败时打印到控制台（避免递归错误）
      if (kDebugMode) {
        print('[LogFileService] Failed to write log entry: $e');
      }
    }
  }

  /// 批量写入日志条目
  Future<void> writeLogEntries(List<LogEntry> entries) async {
    for (final entry in entries) {
      await writeLogEntry(entry);
    }
  }

  /// 读取指定日期的日志
  Future<List<LogEntry>> readLogsByDate(DateTime date) async {
    try {
      final filePath = await getLogFilePath(date);
      final file = File(filePath);

      if (!await file.exists()) {
        return [];
      }

      final lines = await file.readAsLines();
      return lines
          .where((line) => line.trim().isNotEmpty)
          .map((line) {
            try {
              final json = jsonDecode(line) as Map<String, dynamic>;
              return LogEntry.fromJson(json);
            } catch (e) {
              return null;
            }
          })
          .whereType<LogEntry>()
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('[LogFileService] Failed to read logs by date: $e');
      }
      return [];
    }
  }

  /// 读取所有日志
  Future<List<LogEntry>> readAllLogs() async {
    try {
      final logDir = await getLogDirectory();
      final dir = Directory(logDir);

      if (!await dir.exists()) {
        return [];
      }

      final List<LogEntry> allLogs = [];

      // 获取所有日志文件
      final files = dir
          .list()
          .where((entity) =>
              entity is File &&
              entity.path.endsWith(_logFileExtension) &&
              entity.path.contains(_logFilePrefix))
          .cast<File>();

      await for (final file in files) {
        try {
          final lines = await file.readAsLines();
          for (final line in lines) {
            if (line.trim().isEmpty) continue;
            try {
              final json = jsonDecode(line) as Map<String, dynamic>;
              allLogs.add(LogEntry.fromJson(json));
            } catch (_) {
              // 跳过解析失败的行
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('[LogFileService] Failed to read file ${file.path}: $e');
          }
        }
      }

      // 按时间倒序排序
      allLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return allLogs;
    } catch (e) {
      if (kDebugMode) {
        print('[LogFileService] Failed to read all logs: $e');
      }
      return [];
    }
  }

  /// 读取日志（带筛选和分页）
  Future<List<LogEntry>> readLogs({
    LogFilter? filter,
    int? limit,
    int? offset,
  }) async {
    var logs = await readAllLogs();

    // 应用筛选条件
    if (filter != null && !filter.isEmpty) {
      logs = logs.where((log) => filter.matches(log)).toList();
    }

    // 应用分页
    if (offset != null && offset > 0) {
      logs = logs.skip(offset).toList();
    }

    if (limit != null && limit > 0) {
      logs = logs.take(limit).toList();
    }

    return logs;
  }

  /// 获取所有日志文件列表
  Future<List<FileSystemEntity>> getLogFiles() async {
    try {
      final logDir = await getLogDirectory();
      final dir = Directory(logDir);

      if (!await dir.exists()) {
        return [];
      }

      final files = await dir.list().toList();
      return files
          .where((entity) =>
              entity is File &&
              entity.path.endsWith(_logFileExtension) &&
              entity.path.contains(_logFilePrefix))
          .toList()
        ..sort((a, b) => b.path.compareTo(a.path)); // 按文件名倒序（日期倒序）
    } catch (e) {
      if (kDebugMode) {
        print('[LogFileService] Failed to get log files: $e');
      }
      return [];
    }
  }

  /// 获取日志文件总大小（字节）
  Future<int> getTotalLogSize() async {
    try {
      final files = await getLogFiles();
      int totalSize = 0;
      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      return totalSize;
    } catch (e) {
      if (kDebugMode) {
        print('[LogFileService] Failed to get total log size: $e');
      }
      return 0;
    }
  }

  /// 获取日志统计信息
  Future<LogStatistics> getStatistics() async {
    try {
      final files = await getLogFiles();
      final logs = await readAllLogs();

      int errorCount = 0;
      int warningCount = 0;
      int infoCount = 0;
      int debugCount = 0;

      for (final log in logs) {
        switch (log.level) {
          case LogLevel.error:
            errorCount++;
            break;
          case LogLevel.warning:
            warningCount++;
            break;
          case LogLevel.info:
            infoCount++;
            break;
          case LogLevel.debug:
            debugCount++;
            break;
        }
      }

      return LogStatistics(
        totalFiles: files.length,
        totalLogs: logs.length,
        totalSizeBytes: await getTotalLogSize(),
        errorCount: errorCount,
        warningCount: warningCount,
        infoCount: infoCount,
        debugCount: debugCount,
        oldestLogTime: logs.isNotEmpty ? logs.last.timestamp : null,
        newestLogTime: logs.isNotEmpty ? logs.first.timestamp : null,
      );
    } catch (e) {
      if (kDebugMode) {
        print('[LogFileService] Failed to get statistics: $e');
      }
      return LogStatistics.empty();
    }
  }

  /// 删除指定日期之前的日志
  Future<int> deleteLogsBefore(DateTime date) async {
    try {
      final files = await getLogFiles();
      int deletedCount = 0;

      for (final entity in files) {
        if (entity is File) {
          // 从文件名中提取日期
          final fileName = entity.uri.pathSegments.last;
          final dateMatch = RegExp(r'(\d{8})').firstMatch(fileName);

          if (dateMatch != null) {
            final fileDate = DateTime.parse(dateMatch.group(1)!);
            if (fileDate.isBefore(date)) {
              await entity.delete();
              deletedCount++;
            }
          }
        }
      }

      return deletedCount;
    } catch (e) {
      if (kDebugMode) {
        print('[LogFileService] Failed to delete logs before $date: $e');
      }
      return 0;
    }
  }

  /// 删除指定日期的日志
  Future<bool> deleteLogsByDate(DateTime date) async {
    try {
      final filePath = await getLogFilePath(date);
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('[LogFileService] Failed to delete logs by date: $e');
      }
      return false;
    }
  }

  /// 清空所有日志
  Future<int> clearAllLogs() async {
    try {
      final files = await getLogFiles();
      int deletedCount = 0;

      for (final entity in files) {
        if (entity is File) {
          await entity.delete();
          deletedCount++;
        }
      }

      return deletedCount;
    } catch (e) {
      if (kDebugMode) {
        print('[LogFileService] Failed to clear all logs: $e');
      }
      return 0;
    }
  }

  /// 导出日志到单个文件
  Future<File?> exportLogs({
    List<LogEntry>? logs,
    LogFilter? filter,
    bool readable = true,
  }) async {
    try {
      // 获取要导出的日志
      final logsToExport = logs ?? await readLogs(filter: filter);

      if (logsToExport.isEmpty) {
        return null;
      }

      // 创建导出文件
      final Directory tempDir = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final exportFileName = '$_exportFilePrefix$timestamp$_logFileExtension';
      final exportFile = File('${tempDir.path}/$exportFileName');

      // 写入内容
      if (readable) {
        // 可读格式
        final buffer = StringBuffer();
        buffer.writeln('==========================================');
        buffer.writeln('错误日志导出');
        buffer.writeln('导出时间: ${DateTime.now().toString()}');
        buffer.writeln('日志数量: ${logsToExport.length}');
        buffer.writeln('==========================================');
        buffer.writeln();

        for (final log in logsToExport) {
          buffer.writeln(log.toReadableString());
          buffer.writeln();
        }

        await exportFile.writeAsString(buffer.toString());
      } else {
        // JSON Lines格式
        final buffer = StringBuffer();
        for (final log in logsToExport) {
          buffer.writeln(jsonEncode(log.toJson()));
        }
        await exportFile.writeAsString(buffer.toString());
      }

      return exportFile;
    } catch (e) {
      if (kDebugMode) {
        print('[LogFileService] Failed to export logs: $e');
      }
      return null;
    }
  }

  /// 获取日志文件路径列表（用于分享）
  Future<List<String>> getLogFilePaths() async {
    final files = await getLogFiles();
    return files.map((e) => e.path).toList();
  }
}

/// 日志统计信息
class LogStatistics {
  final int totalFiles;
  final int totalLogs;
  final int totalSizeBytes;
  final int errorCount;
  final int warningCount;
  final int infoCount;
  final int debugCount;
  final DateTime? oldestLogTime;
  final DateTime? newestLogTime;

  const LogStatistics({
    required this.totalFiles,
    required this.totalLogs,
    required this.totalSizeBytes,
    required this.errorCount,
    required this.warningCount,
    required this.infoCount,
    required this.debugCount,
    this.oldestLogTime,
    this.newestLogTime,
  });

  factory LogStatistics.empty() {
    return const LogStatistics(
      totalFiles: 0,
      totalLogs: 0,
      totalSizeBytes: 0,
      errorCount: 0,
      warningCount: 0,
      infoCount: 0,
      debugCount: 0,
    );
  }

  /// 获取格式化的文件大小
  String get formattedSize {
    if (totalSizeBytes < 1024) {
      return '$totalSizeBytes B';
    } else if (totalSizeBytes < 1024 * 1024) {
      return '${(totalSizeBytes / 1024).toStringAsFixed(2)} KB';
    } else if (totalSizeBytes < 1024 * 1024 * 1024) {
      return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(totalSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
}
