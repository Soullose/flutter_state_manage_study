import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/error_log/models/error_log_entry.dart';
import '../../../core/error_log/providers/error_log_provider.dart';

/// 错误日志详情页面
class ErrorLogDetailPage extends ConsumerWidget {
  final ErrorLogEntry log;

  const ErrorLogDetailPage({super.key, required this.log});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = _getCategoryColor(log.category, colorScheme);

    return Scaffold(
      appBar: AppBar(
        title: const Text('错误详情'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('分享'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'copy_all',
                child: ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('复制全部'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('删除'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本信息
            _buildSection(
              context,
              '基本信息',
              _buildBasicInfo(context, categoryColor),
            ),
            const SizedBox(height: 16),

            // 错误消息
            _buildSection(
              context,
              '错误消息',
              _buildCopyableContent(context, log.message, colorScheme),
            ),
            const SizedBox(height: 16),

            // 上下文
            if (log.context != null) ...[
              _buildSection(
                context,
                '上下文',
                _buildCopyableContent(context, log.context!, colorScheme),
              ),
              const SizedBox(height: 16),
            ],

            // 堆栈跟踪
            _buildSection(
              context,
              '堆栈跟踪',
              _buildStackTrace(context, colorScheme),
            ),
            const SizedBox(height: 16),

            // 设备信息
            _buildSection(
              context,
              '设备信息',
              _buildDeviceInfo(context, colorScheme),
            ),
            const SizedBox(height: 16),

            // 附加数据
            if (log.additionalData != null &&
                log.additionalData!.isNotEmpty) ...[
              _buildSection(
                context,
                '附加数据',
                _buildAdditionalData(context, colorScheme),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildBasicInfo(BuildContext context, Color categoryColor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              context,
              '分类',
              _getCategoryLabel(log.category),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            ),
            const Divider(),
            _buildInfoRow(context, '时间', _formatDateTime(log.timestamp)),
            const Divider(),
            _buildInfoRow(
              context,
              'ID',
              log.id,
              trailing: IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: log.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ID已复制'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: '复制ID',
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Widget? trailing,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
      ],
    );
  }

  Widget _buildCopyableContent(
    BuildContext context,
    String content,
    ColorScheme colorScheme,
  ) {
    return Card(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16).copyWith(right: 48),
            child: SelectableText(
              content,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: content));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('已复制到剪贴板'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              tooltip: '复制',
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStackTrace(BuildContext context, ColorScheme colorScheme) {
    return Card(
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16).copyWith(right: 48),
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: SelectableText(
                log.stackTrace.isEmpty ? '无堆栈信息' : log.stackTrace,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: log.stackTrace));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('堆栈已复制到剪贴板'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              tooltip: '复制堆栈',
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfo(BuildContext context, ColorScheme colorScheme) {
    final deviceInfo = log.deviceInfo;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(context, '平台', deviceInfo.platform),
            const Divider(),
            _buildInfoRow(context, '系统版本', deviceInfo.osVersion),
            const Divider(),
            _buildInfoRow(context, '设备型号', deviceInfo.deviceModel),
            const Divider(),
            _buildInfoRow(context, '应用版本', deviceInfo.appVersion),
            const Divider(),
            _buildInfoRow(context, '构建号', deviceInfo.buildNumber),
            if (deviceInfo.brand != null) ...[
              const Divider(),
              _buildInfoRow(context, '品牌', deviceInfo.brand!),
            ],
            if (deviceInfo.manufacturer != null) ...[
              const Divider(),
              _buildInfoRow(context, '制造商', deviceInfo.manufacturer!),
            ],
            if (deviceInfo.language != null) ...[
              const Divider(),
              _buildInfoRow(context, '语言', deviceInfo.language!),
            ],
            if (deviceInfo.isPhysicalDevice != null) ...[
              const Divider(),
              _buildInfoRow(
                context,
                '设备类型',
                deviceInfo.isPhysicalDevice! ? '物理设备' : '模拟器',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalData(BuildContext context, ColorScheme colorScheme) {
    return Card(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16).copyWith(right: 48),
            child: SelectableText(
              _formatJson(log.additionalData!),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: _formatJson(log.additionalData!)),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('已复制到剪贴板'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              tooltip: '复制',
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'share':
        _shareLog(context);
        break;
      case 'copy_all':
        _copyAll(context);
        break;
      case 'delete':
        _deleteLog(context, ref);
        break;
    }
  }

  void _shareLog(BuildContext context) {
    final content = _formatLogForSharing();
    SharePlus.instance.share(
      ShareParams(
        text: content,
        subject: '错误日志 - ${_getCategoryLabel(log.category)}',
      ),
    );
  }

  void _copyAll(BuildContext context) {
    final content = _formatLogForSharing();
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制全部内容'), duration: Duration(seconds: 2)),
    );
  }

  Future<void> _deleteLog(BuildContext context, WidgetRef ref) async {
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
      await ref.read(errorLogListProvider.notifier).deleteLog(log.id);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('日志已删除'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _formatLogForSharing() {
    final buffer = StringBuffer();
    buffer.writeln('=== 错误日志 ===');
    buffer.writeln('分类: ${_getCategoryLabel(log.category)}');
    buffer.writeln('时间: ${_formatDateTime(log.timestamp)}');
    buffer.writeln('ID: ${log.id}');
    buffer.writeln();
    buffer.writeln('--- 错误消息 ---');
    buffer.writeln(log.message);
    if (log.context != null) {
      buffer.writeln();
      buffer.writeln('--- 上下文 ---');
      buffer.writeln(log.context);
    }
    buffer.writeln();
    buffer.writeln('--- 堆栈跟踪 ---');
    buffer.writeln(log.stackTrace);
    buffer.writeln();
    buffer.writeln('--- 设备信息 ---');
    buffer.writeln('平台: ${log.deviceInfo.platform}');
    buffer.writeln('系统版本: ${log.deviceInfo.osVersion}');
    buffer.writeln('设备型号: ${log.deviceInfo.deviceModel}');
    buffer.writeln('应用版本: ${log.deviceInfo.appVersion}');
    buffer.writeln('构建号: ${log.deviceInfo.buildNumber}');
    if (log.additionalData != null && log.additionalData!.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('--- 附加数据 ---');
      buffer.writeln(_formatJson(log.additionalData!));
    }
    return buffer.toString();
  }

  String _formatJson(Map<String, dynamic> json) {
    // 简单的 JSON 格式化
    return json.entries.map((e) => '${e.key}: ${e.value}').join('\n');
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

  String _formatDateTime(DateTime time) {
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} '
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}
