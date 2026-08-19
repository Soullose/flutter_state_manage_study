import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error_log/models/error_log_entry.dart';
import '../../../core/error_log/services/error_log_test_service.dart';

/// 测试结果对话框
class TestResultDialog extends StatelessWidget {
  /// 测试结果列表
  final List<TestResult> results;

  const TestResultDialog({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final successCount = results.where((r) => r.success).length;
    final failureCount = results.where((r) => !r.success).length;
    final allPassed = failureCount == 0;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            allPassed ? Icons.check_circle : Icons.warning,
            color: allPassed ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          const Text('测试结果'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 摘要
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: allPassed
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    label: '总计',
                    value: results.length.toString(),
                    color: colorScheme.onSurface,
                  ),
                  _buildSummaryItem(
                    label: '通过',
                    value: successCount.toString(),
                    color: Colors.green,
                  ),
                  _buildSummaryItem(
                    label: '失败',
                    value: failureCount.toString(),
                    color: Colors.red,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 结果列表
            const Text('详细结果', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index];
                  return _buildResultItem(context, result);
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
        if (results.any((r) => r.success))
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // 跳转到错误日志页面
              context.push('/errorLog');
            },
            icon: const Icon(Icons.list),
            label: const Text('查看日志'),
          ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.7)),
        ),
      ],
    );
  }

  Widget _buildResultItem(BuildContext context, TestResult result) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      dense: true,
      leading: Icon(
        result.success ? Icons.check_circle : Icons.cancel,
        color: result.success ? Colors.green : Colors.red,
        size: 20,
      ),
      title: Text(result.testName, style: const TextStyle(fontSize: 14)),
      subtitle: result.errorMessage != null
          ? Text(
              result.errorMessage!,
              style: TextStyle(fontSize: 12, color: colorScheme.error),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : result.category != null
          ? Text(
              '分类: ${_getCategoryLabel(result.category!)}',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: result.logId != null
          ? TextButton(
              onPressed: () {
                Navigator.pop(context);
                // 跳转到日志详情
                context.push('/errorLog/${result.logId}');
              },
              child: const Text('查看'),
            )
          : null,
    );
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
}
