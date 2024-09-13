part of 'counter_cubit.dart';

/// 密封类型
@immutable
sealed class CounterState {
  final int count;
  const CounterState(this.count);
}

final class CounterInitial extends CounterState {
  const CounterInitial(super.count);
}

final class CounterIncrementPressed extends CounterState {
  const CounterIncrementPressed(super.count);
}

final class CounterDecrementPressed extends CounterState {
  const CounterDecrementPressed(super.count);
}
