import 'package:bloc_mode/core/mqtt/bloc/mqtt_bloc.dart';
import 'package:bloc_mode/core/net/HttpManager.dart';
import 'package:bloc_mode/core/storage/shared_preferences_service.dart';
import 'package:bloc_mode/core/storage/shared_preferences_utils.dart';
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

  injector.registerLazySingleton<SharedPreferencesUtils>(
      () => SharedPreferencesUtils(prefs: prefs, asyncPrefs: asyncPrefs));

  injector.registerLazySingleton<HttpManager>(() => HttpManager(prefs: prefs));

  injector.registerFactory(() => SharedPreferencesDb());

  injector.registerFactory(() => MainWrapperBloc());

  injector.registerFactory(() => CounterBloc());

  injector.registerFactory(() => CounterCubit());

  injector.registerFactory(() => TimerBloc(ticker: const Ticker()));

  injector.registerFactory(() => MqttBloc());
}
