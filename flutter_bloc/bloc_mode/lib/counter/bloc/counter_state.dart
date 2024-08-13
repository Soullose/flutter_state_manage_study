import 'package:equatable/equatable.dart';

class CounterState extends Equatable {
  const CounterState._({
    this.counter = 0,
  });

  const CounterState.init() : this._();

  const CounterState.increment(int v) : this._(counter: v);

  final int counter;

  @override
  // TODO: implement props
  List<Object?> get props => [counter];
}
