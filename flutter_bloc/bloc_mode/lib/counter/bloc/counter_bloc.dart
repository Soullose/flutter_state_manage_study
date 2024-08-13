import 'package:bloc/bloc.dart';
import 'package:bloc_mode/counter/bloc/counter_event.dart';
import 'package:bloc_mode/counter/bloc/counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState.init()) {
    // on<InitCountEvent>((event, emit) => _init(event, emit));
    // on<IncrementCountEvent>((event, emit) => _increment(event, emit));
    on<InitCountEvent>(_init);
    on<IncrementCountEvent>(_increment);
  }

  void _init(InitCountEvent event, Emitter<CounterState> emit) {
    emit(const CounterState.init());
  }

  _increment(IncrementCountEvent event, Emitter<CounterState> emit) {
    emit(CounterState.increment(state.counter + 1));
  }
}
