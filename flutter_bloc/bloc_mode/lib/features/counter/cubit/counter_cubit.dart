import 'package:bloc/bloc.dart';
import 'package:bloc_mode/core/utils/app_logger.dart';
import 'package:meta/meta.dart';

part 'counter_state.dart';

/// 全局日志实例
final log = AppLogger.logger;

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(const CounterInitial(0));

  void increment() {
    log.d('加1');
    emit(CounterIncrementPressed(state.count + 1));
  }

  void decrement() {
    log.d('减1');
    emit(CounterDecrementPressed(state.count - 1));
  }
}
