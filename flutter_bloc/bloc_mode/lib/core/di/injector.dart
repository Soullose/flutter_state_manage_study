import 'package:bloc_mode/core/connectivity/bloc/connectivity_bloc.dart';
import 'package:bloc_mode/core/connectivity/service/connectivity_service.dart';
import 'package:bloc_mode/core/mqtt/bloc/mqtt_bloc.dart';
import 'package:bloc_mode/core/net/http_manager.dart';
import 'package:bloc_mode/core/storage/mmkv_service.dart';
import 'package:bloc_mode/core/l10n/bloc/locale_bloc.dart';
import 'package:bloc_mode/core/style/bloc/theme_bloc.dart';
import 'package:bloc_mode/core/utils/app_logger.dart';
import 'package:bloc_mode/features/auth/bloc/auth_bloc.dart';
import 'package:bloc_mode/features/auth/repositories/auth_repository.dart';
import 'package:bloc_mode/features/counter/bloc/counter_bloc.dart';
import 'package:bloc_mode/features/counter/cubit/counter_cubit.dart';
import 'package:bloc_mode/features/main_wrapper/main_wrapper_bloc.dart';
import 'package:bloc_mode/features/timer/bloc/timer_bloc.dart';
import 'package:bloc_mode/features/timer/ticker.dart';
import 'package:get_it/get_it.dart';
import 'package:mmkv/mmkv.dart';

/// 全局日志实例
///
/// 使用 [AppLogger.logger] 统一配置，在 release 模式下自动过滤 debug 级别日志
final log = AppLogger.logger;

final injector = GetIt.instance;

/// 初始化依赖注入
///
/// 此方法必须在 main() 中调用，在使用任何依赖之前完成初始化。
/// MMKV 初始化也会在此方法中完成。
Future<void> initDependencies() async {
  log.d('初始化依赖');

  // 初始化 MMKV
  await MMKV.initialize();
  log.d('MMKV 初始化完成');

  // 初始化 MMKV 数据库服务
  final mmkvDb = MmkvDb();
  await mmkvDb.init();

  // 注册 MMKV 数据库服务 - 单例模式
  injector.registerLazySingleton<MmkvDb>(() => mmkvDb);

  // 网络服务
  injector.registerLazySingleton<HttpManager>(
    () => HttpManager(mmkv: injector()),
  );

  // 全局 Bloc - 单例模式
  injector.registerLazySingleton<ThemeBloc>(() => ThemeBloc(mmkv: injector()));
  injector.registerLazySingleton<LocaleBloc>(
    () => LocaleBloc(mmkv: injector()),
  );

  // 网络连接服务 - 单例
  injector.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(),
  );
  injector.registerLazySingleton<ConnectivityBloc>(
    () => ConnectivityBloc(connectivityService: injector()),
  );

  // 认证相关
  injector.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(mmkv: injector()),
  );
  injector.registerLazySingleton<AuthBloc>(
    () => AuthBloc(authRepository: injector()),
  );

  // 功能 Bloc - 工厂模式
  injector.registerFactory(() => MainWrapperBloc());
  injector.registerFactory(() => CounterBloc());
  injector.registerFactory(() => CounterCubit());
  injector.registerFactory(() => TimerBloc(ticker: const Ticker()));
  injector.registerFactory(() => MqttBloc());
}
