import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/error_log_entry.dart';
import '../services/error_log_storage_service.dart';

/// 错误日志存储服务 Provider
final errorLogStorageServiceProvider = Provider<ErrorLogStorageService>((ref) {
  return ErrorLogStorageService();
});

/// 错误日志列表状态
class ErrorLogListState {
  final List<ErrorLogEntry> logs;
  final bool isLoading;
  final String? error;

  const ErrorLogListState({
    this.logs = const [],
    this.isLoading = false,
    this.error,
  });

  ErrorLogListState copyWith({
    List<ErrorLogEntry>? logs,
    bool? isLoading,
    String? error,
  }) {
    return ErrorLogListState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 错误日志列表 Notifier (使用 Riverpod 3.x Notifier)
class ErrorLogListNotifier extends Notifier<ErrorLogListState> {
  @override
  ErrorLogListState build() {
    return const ErrorLogListState();
  }

  ErrorLogStorageService get _storageService =>
      ref.read(errorLogStorageServiceProvider);

  /// 加载所有日志
  Future<void> loadLogs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final logs = await _storageService.getAllLogs();
      state = ErrorLogListState(logs: logs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 删除指定日志
  Future<bool> deleteLog(String id) async {
    try {
      final success = await _storageService.deleteLog(id);
      if (success) {
        state = state.copyWith(
          logs: state.logs.where((log) => log.id != id).toList(),
        );
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 清空所有日志
  Future<void> clearAllLogs() async {
    try {
      await _storageService.clearAllLogs();
      state = const ErrorLogListState(logs: []);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 按分类筛选日志
  List<ErrorLogEntry> filterByCategory(ErrorCategory? category) {
    if (category == null) {
      return state.logs;
    }
    return state.logs.where((log) => log.category == category).toList();
  }

  /// 搜索日志
  List<ErrorLogEntry> searchLogs(String query) {
    if (query.isEmpty) {
      return state.logs;
    }
    final lowerQuery = query.toLowerCase();
    return state.logs.where((log) {
      return log.message.toLowerCase().contains(lowerQuery) ||
          log.stackTrace.toLowerCase().contains(lowerQuery) ||
          (log.context?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}

/// 错误日志列表 Provider
final errorLogListProvider =
    NotifierProvider<ErrorLogListNotifier, ErrorLogListState>(() {
      return ErrorLogListNotifier();
    });

/// 日志统计信息
class ErrorLogStats {
  final int totalCount;
  final int flutterCount;
  final int platformCount;
  final int networkCount;
  final int storageCount;
  final int businessCount;
  final int uncaughtCount;
  final int fileSize;
  final int fileCount;

  const ErrorLogStats({
    this.totalCount = 0,
    this.flutterCount = 0,
    this.platformCount = 0,
    this.networkCount = 0,
    this.storageCount = 0,
    this.businessCount = 0,
    this.uncaughtCount = 0,
    this.fileSize = 0,
    this.fileCount = 0,
  });

  int getCountByCategory(ErrorCategory category) {
    switch (category) {
      case ErrorCategory.flutter:
        return flutterCount;
      case ErrorCategory.platform:
        return platformCount;
      case ErrorCategory.network:
        return networkCount;
      case ErrorCategory.storage:
        return storageCount;
      case ErrorCategory.business:
        return businessCount;
      case ErrorCategory.uncaught:
        return uncaughtCount;
    }
  }
}

/// 日志统计 Provider
final errorLogStatsProvider = FutureProvider<ErrorLogStats>((ref) async {
  final storageService = ref.watch(errorLogStorageServiceProvider);
  final logs = await storageService.getAllLogs();
  final fileSize = await storageService.getTotalLogSize();
  final fileCount = await storageService.getLogFileCount();

  return ErrorLogStats(
    totalCount: logs.length,
    flutterCount: logs
        .where((log) => log.category == ErrorCategory.flutter)
        .length,
    platformCount: logs
        .where((log) => log.category == ErrorCategory.platform)
        .length,
    networkCount: logs
        .where((log) => log.category == ErrorCategory.network)
        .length,
    storageCount: logs
        .where((log) => log.category == ErrorCategory.storage)
        .length,
    businessCount: logs
        .where((log) => log.category == ErrorCategory.business)
        .length,
    uncaughtCount: logs
        .where((log) => log.category == ErrorCategory.uncaught)
        .length,
    fileSize: fileSize,
    fileCount: fileCount,
  );
});
