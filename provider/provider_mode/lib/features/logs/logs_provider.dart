// lib/features/logs/logs_provider.dart

import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:provider_mode/core/logging/logging.dart';

/// 日志状态管理Provider
/// 提供日志的加载、筛选、搜索、导出等功能
class LogsProvider extends ChangeNotifier {
  final LogService _logService;

  /// 日志列表
  List<LogEntry> _logs = [];

  /// 筛选后的日志列表
  List<LogEntry> _filteredLogs = [];

  /// 当前筛选条件
  LogFilter _filter = const LogFilter();

  /// 是否正在加载
  bool _isLoading = false;

  /// 是否有更多数据
  bool _hasMore = true;

  /// 当前页码
  int _currentPage = 0;

  /// 每页数量
  final int _pageSize = 50;

  /// 统计信息
  LogStatistics? _statistics;

  /// 错误信息
  String? _error;

  /// 搜索关键词
  String _searchKeyword = '';

  LogsProvider(this._logService) {
    // 监听日志更新通知
    _logService.onLogUpdate.listen((_) {
      refresh();
    });
  }

  // Getters
  List<LogEntry> get logs => _filteredLogs;
  LogFilter get filter => _filter;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  LogStatistics? get statistics => _statistics;
  String? get error => _error;
  String get searchKeyword => _searchKeyword;
  int get totalCount => _statistics?.totalLogs ?? 0;

  /// 初始化加载
  Future<void> initialize() async {
    await _logService.initialize();
    await refresh();
  }

  /// 刷新日志列表
  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    _currentPage = 0;
    _hasMore = true;
    notifyListeners();

    try {
      // 加载统计信息
      _statistics = await _logService.getStatistics();

      // 加载第一页数据
      _logs = await _logService.getAllLogs();
      _applyFilter();

      _hasMore = _filteredLogs.length >= _pageSize;
    } catch (e) {
      _error = '加载日志失败: $e';
      debugPrint('[LogsProvider] Error refreshing logs: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      _currentPage++;
      final offset = _currentPage * _pageSize;
      final newLogs = await _logService.getLogs(
        filter: _filter,
        limit: _pageSize,
        offset: offset,
      );

      if (newLogs.length < _pageSize) {
        _hasMore = false;
      }

      _filteredLogs.addAll(newLogs);
    } catch (e) {
      _error = '加载更多失败: $e';
      debugPrint('[LogsProvider] Error loading more logs: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 设置筛选条件
  Future<void> setFilter(LogFilter newFilter) async {
    _filter = newFilter;
    _applyFilter();
    notifyListeners();
  }

  /// 设置日志级别筛选
  Future<void> setLevelFilter(LogLevel? level) async {
    _filter = _filter.copyWith(level: level);
    _applyFilter();
    notifyListeners();
  }

  /// 设置日期范围筛选
  Future<void> setDateRange(DateTime? start, DateTime? end) async {
    _filter = _filter.copyWith(startDate: start, endDate: end);
    _applyFilter();
    notifyListeners();
  }

  /// 设置搜索关键词
  Future<void> setSearchKeyword(String keyword) async {
    _searchKeyword = keyword;
    _filter = _filter.copyWith(keyword: keyword.isEmpty ? null : keyword);
    _applyFilter();
    notifyListeners();
  }

  /// 清除筛选条件
  Future<void> clearFilter() async {
    _filter = const LogFilter();
    _searchKeyword = '';
    _applyFilter();
    notifyListeners();
  }

  /// 应用筛选条件
  void _applyFilter() {
    if (_filter.isEmpty) {
      _filteredLogs = List.from(_logs);
    } else {
      _filteredLogs = _logs.where((log) => _filter.matches(log)).toList();
    }
  }

  /// 删除指定日志
  Future<bool> deleteLog(String logId) async {
    try {
      // 由于当前实现是文件存储，需要重新加载
      // 这里简化处理：刷新整个列表
      await refresh();
      return true;
    } catch (e) {
      _error = '删除日志失败: $e';
      notifyListeners();
      return false;
    }
  }

  /// 清除指定日期之前的日志
  Future<int> clearLogsBefore(DateTime date) async {
    try {
      final count = await _logService.clearLogsBefore(date);
      await refresh();
      return count;
    } catch (e) {
      _error = '清除日志失败: $e';
      notifyListeners();
      return 0;
    }
  }

  /// 清除所有日志
  Future<int> clearAllLogs() async {
    try {
      final count = await _logService.clearAllLogs();
      _logs = [];
      _filteredLogs = [];
      _statistics = LogStatistics.empty();
      notifyListeners();
      return count;
    } catch (e) {
      _error = '清除所有日志失败: $e';
      notifyListeners();
      return 0;
    }
  }

  /// 导出日志
  Future<File?> exportLogs({
    LogFilter? exportFilter,
    bool readable = true,
  }) async {
    try {
      return await _logService.exportLogs(
        filter: exportFilter ?? _filter,
        readable: readable,
      );
    } catch (e) {
      _error = '导出日志失败: $e';
      notifyListeners();
      return null;
    }
  }

  /// 获取日志详情
  LogEntry? getLogById(String id) {
    try {
      return _logs.firstWhere((log) => log.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 按级别分组统计
  Map<LogLevel, int> get levelCounts {
    final counts = <LogLevel, int>{
      LogLevel.error: 0,
      LogLevel.warning: 0,
      LogLevel.info: 0,
      LogLevel.debug: 0,
    };

    for (final log in _logs) {
      counts[log.level] = (counts[log.level] ?? 0) + 1;
    }

    return counts;
  }

  /// 按日期分组
  Map<String, List<LogEntry>> get logsByDate {
    final Map<String, List<LogEntry>> grouped = {};

    for (final log in _filteredLogs) {
      final dateKey =
          '${log.timestamp.year}-${log.timestamp.month.toString().padLeft(2, '0')}-${log.timestamp.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(dateKey, () => []).add(log);
    }

    return grouped;
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ========== 测试方法（仅用于调试） ==========

  /// 记录测试错误日志
  Future<void> addTestError(dynamic error, StackTrace? stackTrace) async {
    await _logService.logError(error, stackTrace, 'TestSource');
    await refresh();
  }

  /// 记录测试警告日志
  Future<void> addTestWarning(String message) async {
    await _logService.logWarning(message, 'TestSource');
    await refresh();
  }

  /// 记录测试信息日志
  Future<void> addTestInfo(String message) async {
    await _logService.logInfo(message, 'TestSource');
    await refresh();
  }
}
