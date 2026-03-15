import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:provider_mode/core/logging/global_exception_handler.dart';
import 'package:provider_mode/core/logging/log_service.dart';
import 'package:provider_mode/core/mqtt/mqtt_state.dart';
import 'package:provider_mode/core/router/app_router.dart';
import 'package:provider_mode/core/store/shared_preferences_service.dart';
import 'package:provider_mode/di/injector.dart';
import 'package:provider_mode/features/locale/locale_provider.dart';
import 'package:provider_mode/features/logs/logs_provider.dart';
import 'package:provider_mode/features/settings/settings_provider.dart';
import 'package:provider_mode/features/theme/theme_provider.dart';

import 'core/store/mmkv_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化依赖注入
  await initDependencies();

  // 初始化存储服务
  injector<SharedPreferencesDb>().init();
  injector<MMKVService>().init();

  // 初始化日志服务
  final logService = injector<LogService>();
  await logService.initialize();

  // 设置全局异常捕获
  // 从 Flutter 3.3 开始，PlatformDispatcher.instance.onError 可以捕获所有 Dart 异步错误
  // 不再需要使用 runZonedGuarded
  final exceptionHandler = injector<GlobalExceptionHandler>();
  exceptionHandler.setup();

  // 直接运行应用，异常由 GlobalExceptionHandler 统一处理
  runApp(MultiProvider(
    providers: [
      // 全局状态Provider
      ChangeNotifierProvider.value(value: injector<ThemeProvider>()),
      ChangeNotifierProvider.value(value: injector<LocaleProvider>()),
      ChangeNotifierProvider.value(value: injector<SettingsProvider>()),
      // MQTT状态
      ChangeNotifierProvider.value(value: injector<MqttState>()),
      // 日志管理
      ChangeNotifierProvider.value(value: injector<LogsProvider>()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用Consumer监听主题和语言变化
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp.router(
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
          // 主题配置
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: themeProvider.themeMode,
          // 语言配置
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: localeProvider.locale,
          supportedLocales: localeProvider.supportedLocales,
        );
      },
    );
  }
}
