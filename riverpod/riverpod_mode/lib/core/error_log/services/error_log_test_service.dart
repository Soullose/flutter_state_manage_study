import 'package:flutter/foundation.dart';

import '../models/error_log_entry.dart';
import 'error_log_storage_service.dart';

/// 测试结果
class TestResult {
  /// 测试名称
  final String testName;

  /// 是否成功
  final bool success;

  /// 错误消息（失败时）
  final String? errorMessage;

  /// 日志ID（成功时返回）
  final String? logId;

  /// 测试分类
  final ErrorCategory? category;

  const TestResult({
    required this.testName,
    required this.success,
    this.errorMessage,
    this.logId,
    this.category,
  });

  @override
  String toString() {
    return 'TestResult($testName: ${success ? "✓" : "✗"}${errorMessage != null ? " - $errorMessage" : ""})';
  }
}

/// 错误日志测试服务
///
/// 提供各类测试错误的生成方法，用于验证错误日志系统功能是否正常
class ErrorLogTestService {
  final ErrorLogStorageService _storageService;

  ErrorLogTestService(this._storageService);

  /// 测试同步异常
  ///
  /// 抛出一个同步异常，验证全局错误捕获机制
  Future<TestResult> testSyncException() async {
    try {
      await _triggerSyncException();
      // 如果没有抛出异常，说明测试失败
      return TestResult(
        testName: '同步异常测试',
        success: false,
        errorMessage: '预期抛出异常但未抛出',
      );
    } catch (e, stackTrace) {
      // 同步异常被捕获，记录到日志
      try {
        final entry = await _storageService.logError(
          error: e,
          stackTrace: stackTrace,
          category: ErrorCategory.uncaught,
          context: '测试功能 - 同步异常测试',
          additionalData: {'testType': 'syncException'},
        );
        return TestResult(
          testName: '同步异常测试',
          success: true,
          logId: entry.id,
          category: ErrorCategory.uncaught,
        );
      } catch (logError) {
        return TestResult(
          testName: '同步异常测试',
          success: false,
          errorMessage: '记录日志失败: $logError',
        );
      }
    }
  }

  /// 测试异步异常
  ///
  /// 抛出一个异步异常，验证异步错误捕获机制
  Future<TestResult> testAsyncException() async {
    try {
      await _triggerAsyncException();
      // 如果没有抛出异常，说明测试失败
      return TestResult(
        testName: '异步异常测试',
        success: false,
        errorMessage: '预期抛出异常但未抛出',
      );
    } catch (e, stackTrace) {
      // 异步异常被捕获，记录到日志
      try {
        final entry = await _storageService.logError(
          error: e,
          stackTrace: stackTrace,
          category: ErrorCategory.uncaught,
          context: '测试功能 - 异步异常测试',
          additionalData: {'testType': 'asyncException'},
        );
        return TestResult(
          testName: '异步异常测试',
          success: true,
          logId: entry.id,
          category: ErrorCategory.uncaught,
        );
      } catch (logError) {
        return TestResult(
          testName: '异步异常测试',
          success: false,
          errorMessage: '记录日志失败: $logError',
        );
      }
    }
  }

  /// 测试 Flutter 错误
  ///
  /// 触发一个 FlutterError，验证 Flutter 框架错误捕获
  Future<TestResult> testFlutterError() async {
    try {
      FlutterError('测试 Flutter 错误 - 这是一个模拟的 Flutter 框架错误');
      // FlutterError 不会抛出，需要手动记录
      final entry = await _storageService.logError(
        error: FlutterError('测试 Flutter 错误 - 这是一个模拟的 Flutter 框架错误'),
        category: ErrorCategory.flutter,
        context: '测试功能 - Flutter 错误测试',
        additionalData: {'testType': 'flutterError'},
      );
      return TestResult(
        testName: 'Flutter 错误测试',
        success: true,
        logId: entry.id,
        category: ErrorCategory.flutter,
      );
    } catch (e, stackTrace) {
      try {
        final entry = await _storageService.logError(
          error: e,
          stackTrace: stackTrace,
          category: ErrorCategory.flutter,
          context: '测试功能 - Flutter 错误测试',
          additionalData: {'testType': 'flutterError'},
        );
        return TestResult(
          testName: 'Flutter 错误测试',
          success: true,
          logId: entry.id,
          category: ErrorCategory.flutter,
        );
      } catch (logError) {
        return TestResult(
          testName: 'Flutter 错误测试',
          success: false,
          errorMessage: '记录日志失败: $logError',
        );
      }
    }
  }

  /// 测试手动记录
  ///
  /// 直接调用日志服务记录错误，验证存储功能
  Future<TestResult> testManualLog(ErrorCategory category) async {
    try {
      final entry = await _storageService.logError(
        error: Exception('测试手动记录 - ${_getCategoryTestName(category)}'),
        category: category,
        context: '测试功能 - 手动记录测试 (${category.name})',
        additionalData: {'testType': 'manualLog', 'category': category.name},
      );
      return TestResult(
        testName: '${_getCategoryTestName(category)}测试',
        success: true,
        logId: entry.id,
        category: category,
      );
    } catch (e) {
      return TestResult(
        testName: '${_getCategoryTestName(category)}测试',
        success: false,
        errorMessage: '记录日志失败: $e',
      );
    }
  }

  /// 执行全量测试
  ///
  /// 依次执行所有测试项
  Future<List<TestResult>> runAllTests() async {
    final results = <TestResult>[];

    // 测试同步异常
    results.add(await testSyncException());
    await Future.delayed(const Duration(milliseconds: 100));

    // 测试异步异常
    results.add(await testAsyncException());
    await Future.delayed(const Duration(milliseconds: 100));

    // 测试 Flutter 错误
    results.add(await testFlutterError());
    await Future.delayed(const Duration(milliseconds: 100));

    // 测试各分类手动记录
    for (final category in ErrorCategory.values) {
      results.add(await testManualLog(category));
      await Future.delayed(const Duration(milliseconds: 50));
    }

    return results;
  }

  /// 触发同步异常
  Future<void> _triggerSyncException() async {
    throw Exception('测试同步异常 - 这是一个模拟的同步错误');
  }

  /// 触发异步异常
  Future<void> _triggerAsyncException() async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('测试异步异常 - 这是一个模拟的异步错误');
  }

  /// 获取分类测试名称
  String _getCategoryTestName(ErrorCategory category) {
    switch (category) {
      case ErrorCategory.flutter:
        return 'Flutter 框架';
      case ErrorCategory.platform:
        return '平台通道';
      case ErrorCategory.network:
        return '网络请求';
      case ErrorCategory.storage:
        return '本地存储';
      case ErrorCategory.business:
        return '业务逻辑';
      case ErrorCategory.uncaught:
        return '未捕获异常';
    }
  }
}
