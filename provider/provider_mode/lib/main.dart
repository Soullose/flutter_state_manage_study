import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_mode/core/mqtt/mqtt_server_client_service.dart';
import 'package:provider_mode/core/mqtt/mqtt_state.dart';
import 'package:provider_mode/core/store/shared_preferences_service.dart';
import 'package:provider_mode/counter/counter_provider.dart';
import 'package:provider_mode/di/injector.dart';
import 'package:provider_mode/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  injector<SharedPreferencesDb>().init();
  // await SharedPreferencesDb().init();
  // Provider.debugCheckInvalidValueType = null;
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => injector<MqttState>()),
    ChangeNotifierProvider(create: (_) => injector<MqttServerClientService>()),
    ChangeNotifierProvider(create: (_) => injector<CounterProvider>()),
  ], child: const MyApp()));
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
