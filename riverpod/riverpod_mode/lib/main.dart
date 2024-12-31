import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:riverpod_mode/common/storage/shared_preferences_provider.dart';
import 'package:riverpod_mode/route/app_router.dart';
import 'package:riverpod_mode/utils/app_provider_observer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'generated/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final SharedPreferences prefs = await SharedPreferences.getInstance();
  // final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  runApp(
    ProviderScope(
      observers: [AppProviderObserver()],
      overrides: [
        sharedPreferencesUtilsProvider,
      ],
      child: const MyApp(),
    ),
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
      // builder: (context, child) {
      //   return MaterialApp.router(
      //     routerConfig: AppRouter.router,
      //     theme: FlexThemeData.light(scheme: FlexScheme.bahamaBlue),
      //     darkTheme: FlexThemeData.dark(scheme: FlexScheme.bahamaBlue),
      //     localizationsDelegates: const [
      //       S.delegate,
      //       GlobalMaterialLocalizations.delegate,
      //       GlobalCupertinoLocalizations.delegate,
      //       GlobalWidgetsLocalizations.delegate
      //     ],
      //     supportedLocales: S.delegate.supportedLocales,
      //   );
      // },
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        theme: FlexThemeData.light(scheme: FlexScheme.bahamaBlue),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.bahamaBlue),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: S.delegate.supportedLocales,
      ),
    );
  }
}
