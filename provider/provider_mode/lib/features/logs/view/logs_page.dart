// lib/features/logs/view/logs_page.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:provider_mode/core/logging/logging.dart';
import 'package:provider_mode/features/logs/logs_provider.dart';
import 'package:provider_mode/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.errorLog),
        actions: [
          // 导出按钮
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: l10n.exportLog,
            onPressed: () => _exportLogs(context),
          ),
          // 更多选项
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value, l10n),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear_all',
                child: ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: Text(l10n.clearAllLogs),
                ),
              ),
              PopupMenuItem(
                value: 'clear_before_week',
                child: ListTile(
                  leading: const Icon(Icons.delete_sweep),
                  title: Text(l10n.clearWeekOldLogs),
                ),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: const Icon(Icons.refresh),
                  title: Text(l10n.refresh),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索和筛选栏
          _buildSearchAndFilterBar(context, l10n),
          // 统计信息卡片
          _buildStatisticsCard(context, l10n),
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
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.logs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 64, color: Colors.green),
                        const SizedBox(height: 16),
                        Text(l10n.noLogs, style: const TextStyle(fontSize: 16)),
                        Text(l10n.appRunningNormally,
                            style: const TextStyle(color: Colors.grey)),
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
  Widget _buildSearchAndFilterBar(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              hintText: l10n.searchLog,
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
                child: _buildLevelFilterChip(context, l10n),
              ),
              const SizedBox(width: 8),
              // 日期筛选
              Expanded(
                child: _buildDateFilterButton(context, l10n),
              ),
              const SizedBox(width: 8),
              // 清除筛选
              IconButton(
                icon: const Icon(Icons.filter_alt_off),
                tooltip: l10n.clearFilter,
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
  Widget _buildLevelFilterChip(BuildContext context, AppLocalizations l10n) {
    return DropdownButtonFormField<LogLevel?>(
      initialValue: _selectedLevel,
      decoration: InputDecoration(
        labelText: l10n.logLevel,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      items: [
        DropdownMenuItem(value: null, child: Text(l10n.all)),
        DropdownMenuItem(
            value: LogLevel.error, child: Text('🔴 ${l10n.errorLevel}')),
        DropdownMenuItem(
            value: LogLevel.warning, child: Text('🟡 ${l10n.warningLevel}')),
        DropdownMenuItem(
            value: LogLevel.info, child: Text('🔵 ${l10n.infoLevel}')),
        DropdownMenuItem(
            value: LogLevel.debug, child: Text('⚪ ${l10n.debugLevel}')),
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
  Widget _buildDateFilterButton(BuildContext context, AppLocalizations l10n) {
    String buttonText = l10n.selectDate;
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
          // 🛡️ 2. 核心修复：检查跨越 await 后，当前组件是否还在树上
          if (!context.mounted) return;
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
  Widget _buildStatisticsCard(BuildContext context, AppLocalizations l10n) {
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
              _buildStatItem(context, l10n.totalLogs,
                  stats.totalLogs.toString(), Colors.blue),
              _buildStatItem(context, l10n.errorCount,
                  stats.errorCount.toString(), Colors.red),
              _buildStatItem(context, l10n.warningCount,
                  stats.warningCount.toString(), Colors.orange),
              _buildStatItem(
                  context, l10n.storage, stats.formattedSize, Colors.grey),
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
    final l10n = AppLocalizations.of(context)!;

    // 显示导出选项对话框
    final exportFormat = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exportLog),
        content: Text(l10n.selectExportFormat),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('JSON'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.readableText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );

    if (exportFormat == null) return;
// 🛡️ 第一次跨越 await：使用 context.mounted 检查当前传入的 context 是否还有效
    if (!context.mounted) return;

    // 显示加载指示器
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exporting)),
      );
    }

    final file = await provider.exportLogs(readable: exportFormat);
// 🛡️ 第二次跨越 await：再次检查 context.mounted
    if (!context.mounted) return;

    if (file != null && mounted) {
      // 分享文件
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: l10n.logExportSubject),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exportFailedOrNoLogs)),
      );
    }
  }

  /// 处理菜单操作
  Future<void> _handleMenuAction(
      BuildContext context, String action, AppLocalizations l10n) async {
    final provider = context.read<LogsProvider>();

    switch (action) {
      case 'clear_all':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.confirmClearAll),
            content: Text(l10n.confirmClearAllMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(l10n.clearAllLogs),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          // final count = await provider.clearAllLogs();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.logsCleared)),
            );
          }
        }
        break;

      case 'clear_before_week':
        // final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        // final count = await provider.clearLogsBefore(weekAgo);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.weekOldLogsCleared)),
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.testLogFunction),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.error, color: Colors.red),
              title: Text(l10n.testErrorLog),
              onTap: () {
                Navigator.pop(context);
                _testErrorLog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.orange),
              title: Text(l10n.testWarningLog),
              onTap: () {
                Navigator.pop(context);
                _testWarningLog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: Text(l10n.testInfoLog),
              onTap: () {
                Navigator.pop(context);
                _testInfoLog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: Text(l10n.throwTestException),
              onTap: () {
                Navigator.pop(context);
                throw Exception(l10n.testExceptionMessage);
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
