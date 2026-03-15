// lib/core/logging/global_exception_handler.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
    // 在调试模式下，先调用原始处理器显示错误界面
    _originalFlutterOnError?.call(details);

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

  /// 在Zone中运行应用，捕获异步错误
  static void runWithCatch(void Function() callback,
      {required LogService logService}) {
    runZonedGuarded(
      callback,
      (error, stackTrace) {
        debugPrint('==================== ZONE ERROR ====================');
        debugPrint('Error: $error');
        debugPrint('Stack trace: $stackTrace');
        debugPrint('====================================================');

        logService.logError(error, stackTrace, 'AsyncZone');
      },
    );
  }
}

/// Flutter错误处理器类型
typedef FlutterErrorHandler = void Function(FlutterErrorDetails details);
