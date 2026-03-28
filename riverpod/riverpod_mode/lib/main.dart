import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'bootstrap.dart';
import 'core/error_log/models/error_log_entry.dart';
import 'core/error_log/services/error_log_storage_service.dart';
import 'core/error_log/utils/device_info_collector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化设备信息收集器
  await DeviceInfoCollector().init();

  // 使用 PlatformDispatcher.instance.onError 捕获错误
  // 这是 Flutter 3.x 推荐的错误捕获方式，替代已废弃的 runZonedGuarded
  final PlatformDispatcher dispatcher = PlatformDispatcher.instance;

  // 捕获 Flutter 框架错误
  final FlutterExceptionHandler? originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) async {
    // Debug 模式下打印到控制台
    if (kDebugMode) {
      log(
        'Flutter Error: ${details.exception}',
        stackTrace: details.stack,
        time: DateTime.now(),
        level: 1000,
        name: 'FlutterError',
      );
    }

    // 记录到本地存储
    await ErrorLogStorageService().logError(
      error: details.exception,
      stackTrace: details.stack,
      category: _toErrorCategory(details.exception),
      context: details.context?.toString(),
    );

    // 调用原始错误处理（保持默认行为）
    originalOnError?.call(details);
  };

  // 捕获平台级别的未处理异常
  dispatcher.onError = (error, stackTrace) {
    // Debug 模式下打印到控制台
    if (kDebugMode) {
      log(
        'Platform Error: $error',
        stackTrace: stackTrace,
        time: DateTime.now(),
        level: 1000,
        name: 'PlatformError',
      );
    }

    // 记录到本地存储
    ErrorLogStorageService().logError(
      error: error,
      stackTrace: stackTrace,
      category: ErrorCategory.uncaught,
    );

    // 返回 true 表示已处理
    return true;
  };

  // 启动应用
  await bootstrap();
}

/// 将错误转换为分类
ErrorCategory _toErrorCategory(Object error) {
  final exceptionStr = error.toString().toLowerCase();

  // 根据错误内容判断分类
  if (exceptionStr.contains('network') ||
      exceptionStr.contains('socket') ||
      exceptionStr.contains('http') ||
      exceptionStr.contains('dio') ||
      exceptionStr.contains('connection')) {
    return ErrorCategory.network;
  }

  if (exceptionStr.contains('storage') ||
      exceptionStr.contains('file') ||
      exceptionStr.contains('database') ||
      exceptionStr.contains('mmkv') ||
      exceptionStr.contains('shared_preferences')) {
    return ErrorCategory.storage;
  }

  if (exceptionStr.contains('platform') ||
      exceptionStr.contains('channel') ||
      exceptionStr.contains('methodchannel')) {
    return ErrorCategory.platform;
  }

  // 默认为 Flutter 框架错误
  return ErrorCategory.flutter;
}
