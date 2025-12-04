import 'dart:io';

import 'package:bloc_mode/core/bloc_observer.dart';
import 'package:bloc_mode/core/di/injector.dart';
import 'package:bloc_mode/core/mqtt/bloc/mqtt_bloc.dart';
import 'package:bloc_mode/core/router/app_router.dart';
import 'package:bloc_mode/core/style/mt_theme.dart';
import 'package:bloc_mode/core/style/snack_bar.dart';
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
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<MqttBloc>(create: (BuildContext context) => MqttBloc())
      ],
      child: const MyApp(),
    ),
    // RepositoryProvider(
    //   create: (context) => null,
    //   child: const MyApp(),
    // ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: scaffoldMessengerKey,
          routerConfig: AppRouter.router,
          theme: const MaterialTheme(TextTheme()).light().copyWith(
              // pageTransitionsTheme: const PageTransitionsTheme(
              //   builders: <TargetPlatform, PageTransitionsBuilder>{
              //     TargetPlatform.android: ZoomPageTransitionsBuilder(),
              //   },
              // ),
              ),
        );
      },
    );
  }
}
