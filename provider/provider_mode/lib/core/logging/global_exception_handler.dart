// lib/core/logging/global_exception_handler.dart

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'log_service.dart';

/// 全局异常处理器
/// 捕获Flutter框架错误、Dart错误和异步错误
class GlobalExceptionHandler {
  final LogService _logService;

  /// 是否在控制台打印错误
  final bool printToConsole;

  /// 是否记录到文件
  final bool logToFile;

  /// 自定义错误处理回调
  void Function(dynamic error, StackTrace? stackTrace)? onError;

  /// 错误通知流控制器 — UI 层可以监听此流展示 SnackBar
  final StreamController<String> _errorStreamController =
      StreamController<String>.broadcast();

  /// 暴露给 UI 层的错误通知流
  Stream<String> get errorStream => _errorStreamController.stream;

  GlobalExceptionHandler({
    required LogService logService,
    this.printToConsole = true,
    this.logToFile = true,
    this.onError,
  }) : _logService = logService;

  /// 设置全局异常捕获
  void setup() {
    // 先保存原始的Flutter错误处理器（在设置新的之前）
    _originalFlutterOnError = FlutterError.onError;

    // 捕获Flutter框架错误
    FlutterError.onError = _handleFlutterError;

    // 捕获Dart层面未处理的异步错误
    PlatformDispatcher.instance.onError = _handlePlatformError;

    debugPrint(
        '[GlobalExceptionHandler] Global exception handler setup complete');
  }

  /// 保存原始的Flutter错误处理器
  FlutterErrorHandler? _originalFlutterOnError;

  /// 处理Flutter框架错误
  void _handleFlutterError(FlutterErrorDetails details) {
    // 打印到控制台
    if (printToConsole) {
      debugPrint('==================== FLUTTER ERROR ====================');
      debugPrint('Error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
      if (details.context != null) {
        debugPrint('Context: ${details.context}');
      }
      if (details.library != null) {
        debugPrint('Library: ${details.library}');
      }
      debugPrint('========================================================');
    }

    // 记录到文件
    if (logToFile) {
      _logService.logError(
        details.exception,
        details.stack,
        _getErrorSource(details),
        _getAdditionalData(details),
      );
    }

    // 通知 UI
    _errorStreamController.add('应用错误: ${details.exception}');

    // 调用自定义回调
    onError?.call(details.exception, details.stack);
  }

  /// 处理平台层面错误
  bool _handlePlatformError(Object error, StackTrace stackTrace) {
    // 打印到控制台
    if (printToConsole) {
      debugPrint('==================== PLATFORM ERROR ====================');
      debugPrint('Error: $error');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('=========================================================');
    }

    // 记录到文件
    if (logToFile) {
      _logService.logError(
        error,
        stackTrace,
        'Platform',
      );
    }

    // 通知 UI
    _errorStreamController.add('系统错误: $error');

    // 调用自定义回调
    onError?.call(error, stackTrace);

    // 返回true表示已处理，false表示继续传递
    return true;
  }

  /// 获取错误来源
  String? _getErrorSource(FlutterErrorDetails details) {
    if (details.context != null) {
      return details.context.toString();
    }
    if (details.library != null) {
      return details.library;
    }
    return null;
  }

  /// 获取附加数据
  Map<String, dynamic>? _getAdditionalData(FlutterErrorDetails details) {
    final data = <String, dynamic>{};

    if (details.context != null) {
      data['context'] = details.context.toString();
    }
    if (details.library != null) {
      data['library'] = details.library;
    }
    if (details.silent) {
      data['silent'] = true;
    }

    return data.isEmpty ? null : data;
  }

  /// 手动记录错误
  Future<void> logError(
    dynamic error, [
    StackTrace? stackTrace,
    String? source,
  ]) async {
    // 打印到控制台
    if (printToConsole) {
      debugPrint('==================== MANUAL ERROR LOG ====================');
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
      if (source != null) {
        debugPrint('Source: $source');
      }
      debugPrint('==========================================================');
    }

    // 记录到文件
    if (logToFile) {
      await _logService.logError(error, stackTrace, source);
    }

    // 调用自定义回调
    onError?.call(error, stackTrace);
  }
}

/// Flutter错误处理器类型
typedef FlutterErrorHandler = void Function(FlutterErrorDetails details);
