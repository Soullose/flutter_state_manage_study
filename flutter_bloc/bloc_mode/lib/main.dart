import 'dart:io';

import 'package:bloc_mode/core/bloc_observer.dart';
import 'package:bloc_mode/core/connectivity/bloc/connectivity_bloc.dart';
import 'package:bloc_mode/core/connectivity/widgets/connectivity_banner.dart';
import 'package:bloc_mode/core/di/injector.dart';
import 'package:bloc_mode/core/l10n/bloc/locale_bloc.dart';
import 'package:bloc_mode/core/mqtt/bloc/mqtt_bloc.dart';
import 'package:bloc_mode/core/router/app_router.dart';
import 'package:bloc_mode/core/style/bloc/theme_bloc.dart';
import 'package:bloc_mode/core/style/mt_theme.dart';
import 'package:bloc_mode/core/style/snack_bar.dart';
import 'package:bloc_mode/features/auth/bloc/auth_bloc.dart';
import 'package:bloc_mode/features/auth/bloc/auth_event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  Bloc.observer = MyObserver();
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  final Directory appDocDir = await getApplicationDocumentsDirectory();
  final String appDocPath = appDocDir.path;
  if (kDebugMode) {
    print('测试app路径:$appDocPath');
  }
  // 启动时加载保存的主题设置
  injector<ThemeBloc>().add(const ThemeLoadedFromStorage());
  // 启动时加载保存的语言设置
  injector<LocaleBloc>().add(const LocaleLoadedFromStorage());

  runApp(
    MultiBlocProvider(
      providers: [
        // 全局 Bloc - 单例
        BlocProvider<ThemeBloc>(
          create: (BuildContext context) => injector<ThemeBloc>(),
        ),
        // LocaleBloc - 全局语言状态管理
        BlocProvider<LocaleBloc>(
          create: (BuildContext context) => injector<LocaleBloc>(),
        ),
        BlocProvider<MqttBloc>(create: (BuildContext context) => MqttBloc()),
        // AuthBloc - 全局认证状态管理
        BlocProvider<AuthBloc>(
          create: (BuildContext context) =>
              injector<AuthBloc>()..add(const AuthStarted()),
        ),
        // ConnectivityBloc - 全局网络状态管理
        BlocProvider<ConnectivityBloc>(
          create: (BuildContext context) => injector<ConnectivityBloc>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        // 使用 BlocBuilder 监听主题状态变化
        return BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              scaffoldMessengerKey: scaffoldMessengerKey,
              routerConfig: AppRouter.router,
              // 根据ThemeBloc状态切换主题
              theme: const MaterialTheme(TextTheme()).light(),
              darkTheme: const MaterialTheme(TextTheme()).dark(),
              themeMode: themeState.themeMode,
              // 使用 builder 将 ConnectivityBanner 放在 MaterialApp 内部
              builder: (context, child) {
                return ConnectivityBanner(child: child!);
              },
            );
          },
        );
      },
    );
  }
}
