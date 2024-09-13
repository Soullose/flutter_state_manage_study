import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

part 'counter_state.dart';

var log = Logger();

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(const CounterInitial(0));

  void increment() {
    log.i('加1');
    emit(CounterIncrementPressed(state.count + 1));
  }

  void decrement() {
    log.i('减1');
    emit(CounterDecrementPressed(state.count - 1));
  }
}
