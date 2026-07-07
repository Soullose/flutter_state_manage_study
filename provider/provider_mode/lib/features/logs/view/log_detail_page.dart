// lib/features/logs/view/log_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'package:provider_mode/core/logging/logging.dart';
import 'package:provider_mode/l10n/app_localizations.dart';

/// 日志详情页面
/// 显示单条日志的完整信息，包括错误消息、堆栈跟踪和设备信息
class LogDetailPage extends StatelessWidget {
  final LogEntry log;

  const LogDetailPage({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(log.errorType ?? l10n.logDetail),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: l10n.copy,
            onPressed: () => _copyToClipboard(context, l10n),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: l10n.share,
            onPressed: () => _shareLog(context, l10n),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本信息
            _buildInfoCard(context, l10n),
            const SizedBox(height: 16),
            // 错误消息
            _buildMessageCard(context, l10n),
            const SizedBox(height: 16),
            // 堆栈跟踪
            if (log.stackTrace != null && log.stackTrace!.isNotEmpty) ...[
              _buildStackTraceCard(context, l10n),
              const SizedBox(height: 16),
            ],
            // 设备信息
            if (log.metadata != null) ...[
              _buildMetadataCard(context, l10n),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建基本信息卡片
  Widget _buildInfoCard(BuildContext context, AppLocalizations l10n) {
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
            _buildInfoRow(l10n.time, log.formattedFullTime),
            if (log.errorType != null)
              _buildInfoRow(l10n.errorType, log.errorType!),
            if (log.source != null) _buildInfoRow(l10n.source, log.source!),
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
  Widget _buildMessageCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.errorMessage,
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
  Widget _buildStackTraceCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.stackTrace,
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
  Widget _buildMetadataCard(BuildContext context, AppLocalizations l10n) {
    final metadata = log.metadata!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.deviceInfo,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Divider(height: 16),
            _buildInfoRow(l10n.appVersion,
                '${metadata.appVersion} (${metadata.buildNumber})'),
            _buildInfoRow(l10n.deviceModel, metadata.deviceModel),
            if (metadata.deviceManufacturer != null)
              _buildInfoRow(l10n.manufacturer, metadata.deviceManufacturer!),
            _buildInfoRow(l10n.systemVersion, metadata.osVersion),
            _buildInfoRow(l10n.platform, metadata.platform),
            if (metadata.networkType != null)
              _buildInfoRow(l10n.networkType, metadata.networkType!),
            if (metadata.timezone != null)
              _buildInfoRow(l10n.timezone, metadata.timezone!),
            if (metadata.locale != null)
              _buildInfoRow(l10n.language, metadata.locale!),
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
  void _copyToClipboard(BuildContext context, AppLocalizations l10n) {
    final text = log.toReadableString();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.copiedToClipboard)),
    );
  }

  /// 分享日志
  Future<void> _shareLog(BuildContext context, AppLocalizations l10n) async {
    final text = log.toReadableString();
    await SharePlus.instance
        .share(ShareParams(text: text, subject: l10n.logDetailSubject));
  }
}
