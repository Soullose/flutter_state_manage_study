import 'package:equatable/equatable.dart';

sealed class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object> get props => [];
}

class InitCountEvent extends CounterEvent {}

final class IncrementCountEvent extends CounterEvent {
  const IncrementCountEvent();
}
