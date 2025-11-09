import 'package:get_it/get_it.dart';
import 'package:provider_mode/core/event/event_bus.dart';
import 'package:provider_mode/core/mqtt/mqtt_server_client_service.dart';
import 'package:provider_mode/core/mqtt/mqtt_state.dart';
import 'package:provider_mode/core/mqtt/mqtt_state_manager.dart';
import 'package:provider_mode/core/store/mmkv_service.dart';
import 'package:provider_mode/core/store/shared_preferences_service.dart';
import 'package:provider_mode/counter/counter_provider.dart';

final injector = GetIt.instance;

Future<void> initDependencies() async {
  injector.registerFactory(() => CounterProvider());
  injector.registerFactory(() => SharedPreferencesDb());
  injector.registerFactory(() => MMKVService());
  // 使用单例模式注册MqttState，确保整个应用使用同一个实例
  injector.registerLazySingleton(() => MqttState());
  // 注册事件总线为单例
  injector.registerLazySingleton(() => EventBus());
  // 注册MqttStateManager为单例，并注入EventBus和MqttState
  injector.registerLazySingleton(
      () => MqttStateManager(injector<EventBus>(), injector<MqttState>()));
  // 注册MqttServerClientService，现在它通过事件总线与状态管理器通信
  injector.registerFactory(() => MqttServerClientService());
}
