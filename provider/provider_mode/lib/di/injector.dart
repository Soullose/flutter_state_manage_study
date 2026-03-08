import 'package:get_it/get_it.dart';
import 'package:provider_mode/core/event/event_bus.dart';
import 'package:provider_mode/core/mqtt/mqtt_server_client_service.dart';
import 'package:provider_mode/core/mqtt/mqtt_state.dart';
import 'package:provider_mode/core/mqtt/mqtt_state_manager.dart';
import 'package:provider_mode/core/store/mmkv_service.dart';
import 'package:provider_mode/core/store/shared_preferences_service.dart';
import 'package:provider_mode/features/counter/counter_provider.dart';
import 'package:provider_mode/features/locale/locale_provider.dart';
import 'package:provider_mode/features/settings/settings_provider.dart';
import 'package:provider_mode/features/theme/theme_provider.dart';

final injector = GetIt.instance;

Future<void> initDependencies() async {
  // 存储服务
  injector.registerFactory(() => SharedPreferencesDb());
  injector.registerFactory(() => MMKVService());

  // 功能Provider
  injector.registerFactory(() => CounterProvider());
  injector
      .registerFactory(() => ThemeProvider(injector<SharedPreferencesDb>()));
  injector
      .registerFactory(() => LocaleProvider(injector<SharedPreferencesDb>()));
  injector
      .registerFactory(() => SettingsProvider(injector<SharedPreferencesDb>()));

  // MQTT相关 - 使用单例模式
  injector.registerLazySingleton(() => MqttState());
  injector.registerLazySingleton(() => EventBus());
  injector.registerLazySingleton(
      () => MqttStateManager(injector<EventBus>(), injector<MqttState>()));
  injector.registerFactory(() => MqttServerClientService());
}
