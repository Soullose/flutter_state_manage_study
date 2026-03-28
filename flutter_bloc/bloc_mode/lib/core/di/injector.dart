import 'package:bloc_mode/core/connectivity/bloc/connectivity_bloc.dart';
import 'package:bloc_mode/core/connectivity/service/connectivity_service.dart';
import 'package:bloc_mode/core/mqtt/bloc/mqtt_bloc.dart';
import 'package:bloc_mode/core/net/http_manager.dart';
import 'package:bloc_mode/core/storage/shared_preferences_service.dart';
import 'package:bloc_mode/core/storage/shared_preferences_utils.dart';
import 'package:bloc_mode/core/l10n/bloc/locale_bloc.dart';
import 'package:bloc_mode/core/style/bloc/theme_bloc.dart';
import 'package:bloc_mode/features/auth/bloc/auth_bloc.dart';
import 'package:bloc_mode/features/auth/repositories/auth_repository.dart';
import 'package:bloc_mode/features/counter/bloc/counter_bloc.dart';
import 'package:bloc_mode/features/counter/cubit/counter_cubit.dart';
import 'package:bloc_mode/features/main_wrapper/main_wrapper_bloc.dart';
import 'package:bloc_mode/features/timer/bloc/timer_bloc.dart';
import 'package:bloc_mode/features/timer/ticker.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

var log = Logger();

final injector = GetIt.instance;

Future<void> initDependencies() async {
  log.i('初始化依赖');

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  // 存储服务
  injector.registerLazySingleton<SharedPreferencesUtils>(
    () => SharedPreferencesUtils(prefs: prefs, asyncPrefs: asyncPrefs),
  );

  // 网络服务
  injector.registerLazySingleton<HttpManager>(() => HttpManager(prefs: prefs));

  // 数据库服务
  injector.registerFactory(() => SharedPreferencesDb());

  // 全局 Bloc - 单例模式
  injector.registerLazySingleton<ThemeBloc>(() => ThemeBloc(prefs: injector()));
  injector.registerLazySingleton<LocaleBloc>(
    () => LocaleBloc(prefs: injector()),
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
    () => AuthRepositoryImpl(prefs: injector()),
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
