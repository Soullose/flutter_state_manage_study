import 'package:equatable/equatable.dart';

class CounterState extends Equatable {
  const CounterState({
    required this.counter
  });

  factory CounterState.init(){
    return const CounterState(counter: 0);
  }

  CounterState copyWith(int count) {
    return CounterState(counter: count);
  }

  factory CounterState.increment(int v) {
    return CounterState(counter: v);
  }

  final int counter;

  @override
  List<Object?> get props => [counter];
}
