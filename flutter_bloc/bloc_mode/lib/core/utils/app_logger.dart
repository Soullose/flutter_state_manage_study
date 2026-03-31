import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// 应用程序统一的日志配置
///
/// 在 debug 模式下输出所有级别的日志（debug 及以上）
/// 在 release 模式下过滤掉 debug 级别的日志（info 及以上）
///
/// 使用方式：
/// ```dart
/// import 'package:bloc_mode/core/utils/app_logger.dart';
///
/// final logger = AppLogger.logger;
/// logger.d('debug 信息');  // release 模式下会被过滤
/// logger.i('info 信息');   // 所有模式都会输出
/// ```
class AppLogger {
  AppLogger._();

  /// 全局 Logger 实例
  ///
  /// 使用自定义的 [Printer] 和 [Filter] 配置：
  /// - Debug 模式：输出 debug 及以上级别
  /// - Release 模式：仅输出 info 及以上级别
  static final Logger logger = Logger(
    printer: _AppLogPrinter(),
    filter: _AppLogFilter(),
  );
}

/// 自定义日志过滤器
///
/// 根据构建模式决定是否输出日志：
/// - Debug/Profile 模式：允许 debug 及以上级别
/// - Release 模式：仅允许 info 及以上级别
class _AppLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // Release 模式下过滤掉 debug 级别的日志
    if (kReleaseMode) {
      return event.level.index >= Level.info.index;
    }
    // Debug 和 Profile 模式下输出所有日志
    return true;
  }
}

/// 自定义日志打印机
///
/// 在 release 模式下使用简化的输出格式，不包含调用栈信息
/// 在 debug 模式下使用完整的 PrettyPrinter 格式
class _AppLogPrinter extends LogPrinter {
  static final PrettyPrinter _prettyPrinter = PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  );

  static final PrettyPrinter _simplePrinter = PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: false,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  );

  @override
  List<String> log(LogEvent event) {
    // Release 模式使用简化格式（无调用栈）
    if (kReleaseMode) {
      return _simplePrinter.log(event);
    }
    // Debug/Profile 模式使用完整格式
    return _prettyPrinter.log(event);
  }
}
