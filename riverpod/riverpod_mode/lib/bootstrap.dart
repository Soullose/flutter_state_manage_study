import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:riverpod_mode/common/theme/dark_theme_provider.dart';
import 'package:riverpod_mode/common/theme/light_theme_provider.dart';
import 'package:riverpod_mode/common/theme/switch_theme_mode.dart';
import 'package:riverpod_mode/route/app_router.dart';

import 'common/state_logger.dart';
import 'common/storage/shared_preferences_provider.dart';
import 'generated/l10n.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final SharedPreferences prefs = await SharedPreferences.getInstance();
  // final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  runApp(
    ProviderScope(
      observers: [
        // AppProviderObserver(),
        StateLogger(),
      ],
      overrides: [sharedPreferencesUtilsProvider],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        themeMode: ref.watch(switchThemeModeProvider),
        theme: ref.watch(lightThemeProvider),
        darkTheme: ref.watch(darkThemeProvider),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
      ),
    );
  }
}
