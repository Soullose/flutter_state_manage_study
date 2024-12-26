import 'package:bloc_mode/di/injector.dart';
import 'package:bloc_mode/router/app_router.dart';
import 'package:bloc_mode/style/mt_theme.dart';
import 'package:flutter/material.dart';

void main() async {
  await initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      theme: const MaterialTheme(TextTheme()).light(),
    );
  }
}
