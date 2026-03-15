// lib/features/logs/view/log_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'package:provider_mode/core/logging/logging.dart';

/// 日志详情页面
/// 显示单条日志的完整信息，包括错误消息、堆栈跟踪和设备信息
class LogDetailPage extends StatelessWidget {
  final LogEntry log;

  const LogDetailPage({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(log.errorType ?? '日志详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: '复制',
            onPressed: () => _copyToClipboard(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: '分享',
            onPressed: () => _shareLog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本信息
            _buildInfoCard(context),
            const SizedBox(height: 16),
            // 错误消息
            _buildMessageCard(context),
            const SizedBox(height: 16),
            // 堆栈跟踪
            if (log.stackTrace != null && log.stackTrace!.isNotEmpty) ...[
              _buildStackTraceCard(context),
              const SizedBox(height: 16),
            ],
            // 设备信息
            if (log.metadata != null) ...[
              _buildMetadataCard(context),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建基本信息卡片
  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(log.level.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  log.level.displayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getLevelColor(log.level),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('ID', log.id),
            _buildInfoRow('时间', log.formattedFullTime),
            if (log.errorType != null) _buildInfoRow('错误类型', log.errorType!),
            if (log.source != null) _buildInfoRow('来源', log.source!),
          ],
        ),
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建错误消息卡片
  Widget _buildMessageCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '错误消息',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Divider(height: 16),
            SelectableText(
              log.message,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建堆栈跟踪卡片
  Widget _buildStackTraceCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '堆栈跟踪',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Divider(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                log.stackTrace!,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建设备信息卡片
  Widget _buildMetadataCard(BuildContext context) {
    final metadata = log.metadata!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '设备信息',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Divider(height: 16),
            _buildInfoRow(
                '应用版本', '${metadata.appVersion} (${metadata.buildNumber})'),
            _buildInfoRow('设备型号', metadata.deviceModel),
            if (metadata.deviceManufacturer != null)
              _buildInfoRow('制造商', metadata.deviceManufacturer!),
            _buildInfoRow('系统版本', metadata.osVersion),
            _buildInfoRow('平台', metadata.platform),
            if (metadata.networkType != null)
              _buildInfoRow('网络类型', metadata.networkType!),
            if (metadata.timezone != null)
              _buildInfoRow('时区', metadata.timezone!),
            if (metadata.locale != null) _buildInfoRow('语言', metadata.locale!),
          ],
        ),
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

  /// 复制到剪贴板
  void _copyToClipboard(BuildContext context) {
    final text = log.toReadableString();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板')),
    );
  }

  /// 分享日志
  Future<void> _shareLog(BuildContext context) async {
    final text = log.toReadableString();
    await Share.share(text, subject: '错误日志详情');
  }
}
