import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error_log/models/error_log_entry.dart';
import '../../../core/error_log/providers/error_log_test_provider.dart';
import '../../../core/error_log/services/error_log_test_service.dart';
import 'test_result_dialog.dart';

/// 错误日志测试面板
class ErrorLogTestPanel extends ConsumerStatefulWidget {
  const ErrorLogTestPanel({super.key});

  @override
  ConsumerState<ErrorLogTestPanel> createState() => _ErrorLogTestPanelState();
}

class _ErrorLogTestPanelState extends ConsumerState<ErrorLogTestPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final testState = ref.watch(errorLogTestProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 标题栏（可点击展开/收起）
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.science_outlined, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    '功能测试',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // 测试结果摘要
                  if (testState.results.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: testState.allPassed
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${testState.successCount}/${testState.results.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: testState.allPassed
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  // 测试中指示器
                  if (testState.isTesting)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    )
                  else
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
            ),
          ),

          // 展开内容
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 基础测试按钮
                  Text(
                    '基础测试',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTestButton(
                        label: '同步异常',
                        icon: Icons.error_outline,
                        color: Colors.red,
                        onPressed: testState.isTesting
                            ? null
                            : () => _executeTest(
                                () => ref
                                    .read(errorLogTestProvider.notifier)
                                    .testSyncException(),
                              ),
                      ),
                      _buildTestButton(
                        label: '异步异常',
                        icon: Icons.sync,
                        color: Colors.orange,
                        onPressed: testState.isTesting
                            ? null
                            : () => _executeTest(
                                () => ref
                                    .read(errorLogTestProvider.notifier)
                                    .testAsyncException(),
                              ),
                      ),
                      _buildTestButton(
                        label: 'Flutter错误',
                        icon: Icons.flutter_dash,
                        color: Colors.blue,
                        onPressed: testState.isTesting
                            ? null
                            : () => _executeTest(
                                () => ref
                                    .read(errorLogTestProvider.notifier)
                                    .testFlutterError(),
                              ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 分类测试按钮
                  Text(
                    '分类测试',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ErrorCategory.values.map((category) {
                      return _buildCategoryTestButton(
                        category: category,
                        onPressed: testState.isTesting
                            ? null
                            : () => _executeTest(
                                () => ref
                                    .read(errorLogTestProvider.notifier)
                                    .testManualLog(category),
                              ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // 操作按钮行
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: testState.isTesting
                              ? null
                              : () => _runAllTests(),
                          icon: testState.isTesting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.play_arrow),
                          label: Text(
                            testState.isTesting ? '测试中...' : '一键全量测试',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (testState.results.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () => _showResults(context, testState),
                          icon: const Icon(Icons.list_alt),
                          label: const Text('查看结果'),
                        ),
                    ],
                  ),

                  // 当前测试提示
                  if (testState.isTesting && testState.currentTest != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '正在执行: ${testState.currentTest}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTestButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTestButton({
    required ErrorCategory category,
    required VoidCallback? onPressed,
  }) {
    final color = _getCategoryColor(category);
    final label = _getCategoryLabel(category);

    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  /// 执行单个测试并显示结果
  Future<void> _executeTest(Future<TestResult> Function() testFn) async {
    try {
      final result = await testFn();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success
                  ? '✓ ${result.testName} 通过'
                  : '✗ ${result.testName} 失败: ${result.errorMessage}',
            ),
            backgroundColor: result.success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('测试执行失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _runAllTests() async {
    await ref.read(errorLogTestProvider.notifier).runAllTests();
    if (mounted) {
      final state = ref.read(errorLogTestProvider);
      _showResults(context, state);
    }
  }

  void _showResults(BuildContext context, ErrorLogTestState state) {
    showDialog(
      context: context,
      builder: (context) => TestResultDialog(results: state.results),
    );
  }

  Color _getCategoryColor(ErrorCategory category) {
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
        return Colors.grey;
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
}
