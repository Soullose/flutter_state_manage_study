import 'package:get_it/get_it.dart';
import 'package:provider_mode/core/event/event_bus.dart';
import 'package:provider_mode/core/logging/global_exception_handler.dart';
import 'package:provider_mode/core/logging/log_file_service.dart';
import 'package:provider_mode/core/logging/log_service.dart';
import 'package:provider_mode/core/mqtt/mqtt_server_client_service.dart';
import 'package:provider_mode/core/mqtt/mqtt_state.dart';
import 'package:provider_mode/core/mqtt/mqtt_state_manager.dart';
import 'package:provider_mode/core/store/mmkv_service.dart';
import 'package:provider_mode/core/store/shared_preferences_service.dart';
import 'package:provider_mode/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:provider_mode/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:provider_mode/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:provider_mode/features/auth/domain/repositories/auth_repository.dart';
import 'package:provider_mode/features/auth/domain/usecases/login_user.dart';
import 'package:provider_mode/features/auth/domain/usecases/logout_user.dart';
import 'package:provider_mode/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:provider_mode/features/counter/counter_provider.dart';
import 'package:provider_mode/features/locale/locale_provider.dart';
import 'package:provider_mode/features/logs/logs_provider.dart';
import 'package:provider_mode/features/settings/settings_provider.dart';
import 'package:provider_mode/features/theme/theme_provider.dart';

final injector = GetIt.instance;

Future<void> initDependencies() async {
  // 存储服务 - 使用懒汉单例（内部已是单例模式，DI 层面也保持一致）
  injector.registerLazySingleton(() => SharedPreferencesDb());
  injector.registerLazySingleton(() => MMKVService());

  // 功能Provider - 使用构造注入
  injector.registerFactory(() => CounterProvider(
        sharedPreferencesDb: injector<SharedPreferencesDb>(),
        mmkvService: injector<MMKVService>(),
      ));
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

  // 日志系统
  injector.registerFactory(() => LogFileService());
  injector.registerLazySingleton(() => LogService());
  injector.registerLazySingleton(() => GlobalExceptionHandler(
        logService: injector<LogService>(),
        printToConsole: true,
        logToFile: true,
      ));
  injector.registerFactory(() => LogsProvider(injector<LogService>()));

  // ========== Auth 认证模块 ==========
  // DataSource（Mock 实现）
  injector.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl());

  // Repository
  injector.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(injector<AuthRemoteDataSource>()));

  // UseCase
  injector.registerFactory(() => LoginUser(injector<AuthRepository>()));
  injector.registerFactory(() => LogoutUser(injector<AuthRepository>()));

  // ViewModel
  injector.registerFactory(() => AuthViewModel(
        loginUser: injector<LoginUser>(),
        logoutUser: injector<LogoutUser>(),
      ));
}
