// lib/features/logs/view/logs_page.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:provider_mode/core/logging/logging.dart';
import 'package:provider_mode/features/logs/logs_provider.dart';
import 'log_detail_page.dart';

/// 日志管理页面
/// 显示应用错误日志列表，支持搜索、筛选、导出和清理功能
class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  final TextEditingController _searchController = TextEditingController();
  LogLevel? _selectedLevel;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LogsProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('错误日志'),
        actions: [
          // 导出按钮
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: '导出日志',
            onPressed: () => _exportLogs(context),
          ),
          // 更多选项
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: ListTile(
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  title: Text('清空所有日志'),
                ),
              ),
              const PopupMenuItem(
                value: 'clear_before_week',
                child: ListTile(
                  leading: Icon(Icons.delete_sweep),
                  title: Text('清除一周前的日志'),
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('刷新'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索和筛选栏
          _buildSearchAndFilterBar(context),
          // 统计信息卡片
          _buildStatisticsCard(context),
          // 日志列表
          Expanded(
            child: Consumer<LogsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.logs.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(provider.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.refresh(),
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.logs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 64, color: Colors.green),
                        SizedBox(height: 16),
                        Text('暂无日志记录', style: TextStyle(fontSize: 16)),
                        Text('应用运行正常', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.refresh(),
                  child: ListView.builder(
                    itemCount:
                        provider.logs.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.logs.length) {
                        // 加载更多指示器
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          provider.loadMore();
                        });
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final log = provider.logs[index];
                      return _buildLogListItem(context, log);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // 测试按钮（仅调试模式）
      floatingActionButton: kDebugMode
          ? FloatingActionButton(
              onPressed: () => _showTestDialog(context),
              child: const Icon(Icons.bug_report),
            )
          : null,
    );
  }

  /// 构建搜索和筛选栏
  Widget _buildSearchAndFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 搜索框
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索日志...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<LogsProvider>().setSearchKeyword('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            onChanged: (value) {
              context.read<LogsProvider>().setSearchKeyword(value);
            },
          ),
          const SizedBox(height: 8),
          // 筛选按钮行
          Row(
            children: [
              // 级别筛选
              Expanded(
                child: _buildLevelFilterChip(context),
              ),
              const SizedBox(width: 8),
              // 日期筛选
              Expanded(
                child: _buildDateFilterButton(context),
              ),
              const SizedBox(width: 8),
              // 清除筛选
              IconButton(
                icon: const Icon(Icons.filter_alt_off),
                tooltip: '清除筛选',
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _selectedLevel = null;
                    _selectedDateRange = null;
                  });
                  context.read<LogsProvider>().clearFilter();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建级别筛选下拉框
  Widget _buildLevelFilterChip(BuildContext context) {
    return DropdownButtonFormField<LogLevel?>(
      value: _selectedLevel,
      decoration: InputDecoration(
        labelText: '日志级别',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('全部')),
        DropdownMenuItem(value: LogLevel.error, child: Text('🔴 错误')),
        DropdownMenuItem(value: LogLevel.warning, child: Text('🟡 警告')),
        DropdownMenuItem(value: LogLevel.info, child: Text('🔵 信息')),
        DropdownMenuItem(value: LogLevel.debug, child: Text('⚪ 调试')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedLevel = value;
        });
        context.read<LogsProvider>().setLevelFilter(value);
      },
    );
  }

  /// 构建日期筛选按钮
  Widget _buildDateFilterButton(BuildContext context) {
    String buttonText = '选择日期';
    if (_selectedDateRange != null) {
      buttonText =
          '${_selectedDateRange!.start.month}/${_selectedDateRange!.start.day} - ${_selectedDateRange!.end.month}/${_selectedDateRange!.end.day}';
    }

    return OutlinedButton.icon(
      onPressed: () async {
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: _selectedDateRange,
        );

        if (range != null) {
          setState(() {
            _selectedDateRange = range;
          });
          context.read<LogsProvider>().setDateRange(range.start, range.end);
        }
      },
      icon: const Icon(Icons.date_range, size: 18),
      label: Text(buttonText, overflow: TextOverflow.ellipsis),
    );
  }

  /// 构建统计信息卡片
  Widget _buildStatisticsCard(BuildContext context) {
    return Consumer<LogsProvider>(
      builder: (context, provider, child) {
        final stats = provider.statistics;
        if (stats == null || stats.totalLogs == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                  context, '总计', stats.totalLogs.toString(), Colors.blue),
              _buildStatItem(
                  context, '错误', stats.errorCount.toString(), Colors.red),
              _buildStatItem(
                  context, '警告', stats.warningCount.toString(), Colors.orange),
              _buildStatItem(context, '大小', stats.formattedSize, Colors.grey),
            ],
          ),
        );
      },
    );
  }

  /// 构建统计项
  Widget _buildStatItem(
      BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// 构建日志列表项
  Widget _buildLogListItem(BuildContext context, LogEntry log) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Text(
          log.level.emoji,
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(
          log.errorType ?? log.shortMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _getLevelColor(log.level),
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              log.shortMessage,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              log.formattedTime,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _navigateToDetail(context, log),
      ),
    );
  }

  /// 获取日志级别对应的颜色
  Color _getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.error:
        return Colors.red;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.debug:
        return Colors.grey;
    }
  }

  /// 导航到详情页
  void _navigateToDetail(BuildContext context, LogEntry log) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogDetailPage(log: log),
      ),
    );
  }

  /// 导出日志
  Future<void> _exportLogs(BuildContext context) async {
    final provider = context.read<LogsProvider>();

    // 显示导出选项对话框
    final exportFormat = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导出日志'),
        content: const Text('选择导出格式：'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('JSON格式'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('可读文本'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('取消'),
          ),
        ],
      ),
    );

    if (exportFormat == null) return;

    // 显示加载指示器
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('正在导出...')),
      );
    }

    final file = await provider.exportLogs(readable: exportFormat);

    if (file != null && mounted) {
      // 分享文件
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: '错误日志导出',
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('导出失败或没有日志可导出')),
      );
    }
  }

  /// 处理菜单操作
  Future<void> _handleMenuAction(BuildContext context, String action) async {
    final provider = context.read<LogsProvider>();

    switch (action) {
      case 'clear_all':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('确认清空'),
            content: const Text('确定要清空所有日志吗？此操作不可恢复。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('清空'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          final count = await provider.clearAllLogs();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('已清空 $count 个日志文件')),
            );
          }
        }
        break;

      case 'clear_before_week':
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        final count = await provider.clearLogsBefore(weekAgo);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已清除 $count 个日志文件')),
          );
        }
        break;

      case 'refresh':
        await provider.refresh();
        break;
    }
  }

  /// 显示测试对话框（调试模式）
  void _showTestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('测试日志功能'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.error, color: Colors.red),
              title: const Text('测试错误日志'),
              onTap: () {
                Navigator.pop(context);
                _testErrorLog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.orange),
              title: const Text('测试警告日志'),
              onTap: () {
                Navigator.pop(context);
                _testWarningLog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: const Text('测试信息日志'),
              onTap: () {
                Navigator.pop(context);
                _testInfoLog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('抛出测试异常'),
              onTap: () {
                Navigator.pop(context);
                throw Exception('这是一个测试异常');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 测试错误日志
  void _testErrorLog() {
    try {
      throw Exception('这是一个测试错误日志');
    } catch (e, stackTrace) {
      context.read<LogsProvider>().addTestError(e, stackTrace);
    }
  }

  /// 测试警告日志
  void _testWarningLog() {
    context.read<LogsProvider>().addTestWarning('这是一个测试警告日志');
  }

  /// 测试信息日志
  void _testInfoLog() {
    context.read<LogsProvider>().addTestInfo('这是一个测试信息日志');
  }
}
