import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/error_log_entry.dart';
import '../services/error_log_test_service.dart';
import 'error_log_provider.dart';

/// 测试服务 Provider
final errorLogTestServiceProvider = Provider<ErrorLogTestService>((ref) {
  final storageService = ref.watch(errorLogStorageServiceProvider);
  return ErrorLogTestService(storageService);
});

/// 测试状态
class ErrorLogTestState {
  /// 是否正在测试
  final bool isTesting;

  /// 测试结果列表
  final List<TestResult> results;

  /// 当前测试名称
  final String? currentTest;

  const ErrorLogTestState({
    this.isTesting = false,
    this.results = const [],
    this.currentTest,
  });

  ErrorLogTestState copyWith({
    bool? isTesting,
    List<TestResult>? results,
    String? currentTest,
  }) {
    return ErrorLogTestState(
      isTesting: isTesting ?? this.isTesting,
      results: results ?? this.results,
      currentTest: currentTest,
    );
  }

  /// 获取成功的测试数量
  int get successCount => results.where((r) => r.success).length;

  /// 获取失败的测试数量
  int get failureCount => results.where((r) => !r.success).length;

  /// 是否全部通过
  bool get allPassed => results.isNotEmpty && failureCount == 0;
}

/// 错误日志测试 Notifier
class ErrorLogTestNotifier extends Notifier<ErrorLogTestState> {
  @override
  ErrorLogTestState build() {
    return const ErrorLogTestState();
  }

  ErrorLogTestService get _testService => ref.read(errorLogTestServiceProvider);

  /// 测试同步异常
  Future<TestResult> testSyncException() async {
    state = state.copyWith(isTesting: true, currentTest: '同步异常测试');
    try {
      final result = await _testService.testSyncException();
      state = state.copyWith(
        isTesting: false,
        currentTest: null,
        results: [...state.results, result],
      );
      // 刷新日志列表
      ref.read(errorLogListProvider.notifier).loadLogs();
      return result;
    } catch (e) {
      state = state.copyWith(isTesting: false, currentTest: null);
      rethrow;
    }
  }

  /// 测试异步异常
  Future<TestResult> testAsyncException() async {
    state = state.copyWith(isTesting: true, currentTest: '异步异常测试');
    try {
      final result = await _testService.testAsyncException();
      state = state.copyWith(
        isTesting: false,
        currentTest: null,
        results: [...state.results, result],
      );
      // 刷新日志列表
      ref.read(errorLogListProvider.notifier).loadLogs();
      return result;
    } catch (e) {
      state = state.copyWith(isTesting: false, currentTest: null);
      rethrow;
    }
  }

  /// 测试 Flutter 错误
  Future<TestResult> testFlutterError() async {
    state = state.copyWith(isTesting: true, currentTest: 'Flutter 错误测试');
    try {
      final result = await _testService.testFlutterError();
      state = state.copyWith(
        isTesting: false,
        currentTest: null,
        results: [...state.results, result],
      );
      // 刷新日志列表
      ref.read(errorLogListProvider.notifier).loadLogs();
      return result;
    } catch (e) {
      state = state.copyWith(isTesting: false, currentTest: null);
      rethrow;
    }
  }

  /// 测试手动记录（按分类）
  Future<TestResult> testManualLog(ErrorCategory category) async {
    state = state.copyWith(isTesting: true, currentTest: '${category.name}测试');
    try {
      final result = await _testService.testManualLog(category);
      state = state.copyWith(
        isTesting: false,
        currentTest: null,
        results: [...state.results, result],
      );
      // 刷新日志列表
      ref.read(errorLogListProvider.notifier).loadLogs();
      return result;
    } catch (e) {
      state = state.copyWith(isTesting: false, currentTest: null);
      rethrow;
    }
  }

  /// 执行全量测试
  Future<List<TestResult>> runAllTests() async {
    state = state.copyWith(isTesting: true, currentTest: '全量测试');
    try {
      final results = await _testService.runAllTests();
      state = state.copyWith(
        isTesting: false,
        currentTest: null,
        results: [...state.results, ...results],
      );
      // 刷新日志列表
      ref.read(errorLogListProvider.notifier).loadLogs();
      return results;
    } catch (e) {
      state = state.copyWith(isTesting: false, currentTest: null);
      rethrow;
    }
  }

  /// 清空测试结果
  void clearResults() {
    state = const ErrorLogTestState();
  }
}

/// 测试状态 Provider
final errorLogTestProvider =
    NotifierProvider<ErrorLogTestNotifier, ErrorLogTestState>(() {
      return ErrorLogTestNotifier();
    });
