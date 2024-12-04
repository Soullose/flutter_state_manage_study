import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:getx_mode/router/app_routes.dart';
import 'package:getx_mode/router/index.dart';
import 'package:getx_mode/style/mt_theme.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 780),
      builder: (context, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'getx状态管理',
        theme: const MaterialTheme(TextTheme()).light(),
        initialRoute: AppRoutes.initial,
        getPages: AppPages.routes,
      ),
    );
  }
}
