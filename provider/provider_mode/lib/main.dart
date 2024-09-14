import 'package:flutter/material.dart';
import 'package:provider_mode/app.dart';
import 'package:provider_mode/di/injector.dart';
import 'package:provider_mode/router/app_router.dart';

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
      routerConfig: AppRouter.router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}
