import 'dart:async';
import 'dart:developer';

import 'bootstrap.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      await bootstrap();
    },
    (error, stack) {
      return log(error.toString(), stackTrace: stack);
    },
  );
  // WidgetsFlutterBinding.ensureInitialized();
  // final SharedPreferences prefs = await SharedPreferences.getInstance();
  // final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  // runApp(
  //   ProviderScope(
  //     observers: [
  //       // AppProviderObserver(),
  //       StateLogger(),
  //     ],
  //     overrides: [
  //       sharedPreferencesUtilsProvider,
  //     ],
  //     child: const MyApp(),
  //   ),
  // );
}
