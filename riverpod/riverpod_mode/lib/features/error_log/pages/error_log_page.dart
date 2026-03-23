import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/error_log/models/error_log_entry.dart';
import '../../../core/error_log/providers/error_log_provider.dart';
import '../widgets/error_log_test_panel.dart';

/// 错误日志列表页面
class ErrorLogPage extends ConsumerStatefulWidget {
  const ErrorLogPage({super.key});

  @override
  ConsumerState<ErrorLogPage> createState() => _ErrorLogPageState();
}

class _ErrorLogPageState extends ConsumerState<ErrorLogPage> {
  ErrorCategory? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 页面加载时获取日志列表
    Future.microtask(() {
      ref.read(errorLogListProvider.notifier).loadLogs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ErrorLogEntry> _filterLogs(List<ErrorLogEntry> logs) {
    var filtered = logs;

    // 按分类筛选
    if (_selectedCategory != null) {
      filtered = filtered
          .where((log) => log.category == _selectedCategory)
          .toList();
    }

    // 搜索过滤
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((log) {
        return log.message.toLowerCase().contains(query) ||
            log.stackTrace.toLowerCase().contains(query) ||
            (log.context?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(errorLogListProvider);
    final stats = ref.watch(errorLogStatsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('错误日志'),
        centerTitle: true,
        actions: [
          // 导出按钮
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: '导出日志',
            onPressed: () => _exportLogs(context),
          ),
          // 清空按钮
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: '清空日志',
            onPressed: state.logs.isEmpty
                ? null
                : () => _showClearConfirmDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 统计信息卡片
          stats.when(
            data: (data) => _buildStatsCard(data, colorScheme),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // 功能测试面板（仅在Debug模式显示）
          if (kDebugMode) const ErrorLogTestPanel(),

          const SizedBox(height: 8),

          // 搜索和筛选
          _buildSearchAndFilter(colorScheme),

          // 日志列表
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? _buildErrorWidget(state.error!)
                : state.logs.isEmpty
                ? _buildEmptyWidget()
                : _buildLogList(state.logs, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(ErrorLogStats stats, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '日志统计',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '共 ${stats.totalCount} 条',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ErrorCategory.values.map((category) {
              final count = stats.getCountByCategory(category);
              return _buildCategoryChip(category, count, colorScheme);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    ErrorCategory category,
    int count,
    ColorScheme colorScheme,
  ) {
    final isSelected = _selectedCategory == category;
    final color = _getCategoryColor(category, colorScheme);

    return FilterChip(
      label: Text('${_getCategoryLabel(category)} ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildSearchAndFilter(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索错误消息、堆栈...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无错误日志',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '应用运行正常，没有记录到任何错误',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text('加载失败', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              ref.read(errorLogListProvider.notifier).loadLogs();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogList(List<ErrorLogEntry> logs, ColorScheme colorScheme) {
    final filteredLogs = _filterLogs(logs);

    if (filteredLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '未找到匹配的日志',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(errorLogListProvider.notifier).loadLogs();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredLogs.length,
        itemBuilder: (context, index) {
          final log = filteredLogs[index];
          return _buildLogItem(log, colorScheme);
        },
      ),
    );
  }

  Widget _buildLogItem(ErrorLogEntry log, ColorScheme colorScheme) {
    final categoryColor = _getCategoryColor(log.category, colorScheme);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/errorLog/${log.id}', extra: log);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部：分类标签和时间
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getCategoryLabel(log.category),
                      style: TextStyle(
                        color: categoryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatTime(log.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 错误消息
              Text(
                log.message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              // 上下文信息
              if (log.context != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Context: ${log.context}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              // 底部操作
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 复制按钮
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: log.message));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('已复制到剪贴板'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('复制'),
                  ),
                  // 删除按钮
                  TextButton.icon(
                    onPressed: () => _deleteLog(log.id),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: colorScheme.error,
                    ),
                    label: Text(
                      '删除',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteLog(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除日志'),
        content: const Text('确定要删除这条日志吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(errorLogListProvider.notifier).deleteLog(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('日志已删除'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _showClearConfirmDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空日志'),
        content: const Text('确定要清空所有错误日志吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('清空'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(errorLogListProvider.notifier).clearAllLogs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('所有日志已清空'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _exportLogs(BuildContext context) async {
    try {
      final storageService = ref.read(errorLogStorageServiceProvider);
      final exportFile = await storageService.exportToFile();

      if (exportFile != null && mounted) {
        // 显示导出选项
        final result = await showModalBottomSheet<String>(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('分享到其他应用'),
                  onTap: () => Navigator.pop(context, 'share'),
                ),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: const Text('复制JSON到剪贴板'),
                  onTap: () => Navigator.pop(context, 'copy'),
                ),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: const Text('取消'),
                  onTap: () => Navigator.pop(context, null),
                ),
              ],
            ),
          ),
        );

        if (result == 'share') {
          await Share.shareXFiles([XFile(exportFile.path)], subject: '错误日志导出');
        } else if (result == 'copy') {
          final jsonString = await storageService.exportAsJsonString();
          await Clipboard.setData(ClipboardData(text: jsonString));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('JSON已复制到剪贴板'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Color _getCategoryColor(ErrorCategory category, ColorScheme colorScheme) {
    switch (category) {
      case ErrorCategory.flutter:
        return Colors.blue;
      case ErrorCategory.platform:
        return Colors.orange;
      case ErrorCategory.network:
        return Colors.red;
      case ErrorCategory.storage:
        return Colors.purple;
      case ErrorCategory.business:
        return Colors.amber;
      case ErrorCategory.uncaught:
        return colorScheme.error;
    }
  }

  String _getCategoryLabel(ErrorCategory category) {
    switch (category) {
      case ErrorCategory.flutter:
        return 'Flutter';
      case ErrorCategory.platform:
        return '平台';
      case ErrorCategory.network:
        return '网络';
      case ErrorCategory.storage:
        return '存储';
      case ErrorCategory.business:
        return '业务';
      case ErrorCategory.uncaught:
        return '未捕获';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${time.month}-${time.day} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
