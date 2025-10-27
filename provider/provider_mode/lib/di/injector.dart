import 'package:get_it/get_it.dart';
import 'package:provider_mode/core/mqtt/mqtt_server_client_service.dart';
import 'package:provider_mode/core/mqtt/mqtt_state.dart';
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
  // 更新MqttServerClientService注册，传递MqttState实例
  injector.registerFactory(() => MqttServerClientService());
}
