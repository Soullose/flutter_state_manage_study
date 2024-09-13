import 'package:bloc_mode/counter/bloc/counter_bloc.dart';
import 'package:bloc_mode/counter/cubit/counter_cubit.dart';
import 'package:bloc_mode/timer/bloc/timer_bloc.dart';
import 'package:bloc_mode/timer/ticker.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

var log = Logger();

final injector = GetIt.instance;

Future<void> initDependencies() async {
  log.i('初始化依赖');
  injector.registerFactory(() => CounterBloc());

  injector.registerFactory(() => CounterCubit());

  injector.registerFactory(() => TimerBloc(ticker: const Ticker()));
}
