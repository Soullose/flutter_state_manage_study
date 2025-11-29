import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
sealed class TimerState extends Equatable {
  final int duration;

  const TimerState(this.duration);

  @override
  List<Object> get props {
    return [duration];
  }
}

final class TimeStateInitial extends TimerState {
  const TimeStateInitial(super.duration);

  @override
  List<Object> get props => [duration];

  @override
  String toString() => 'TimeStateInitial duration: $duration';
}

/// 定时器暂停
final class TimerRunPause extends TimerState {
  const TimerRunPause(super.duration);

  @override
  String toString() => 'TimerRunPause { duration: $duration }';
}

/// 定时器运行中
final class TimerRunInProgress extends TimerState {
  const TimerRunInProgress(super.duration);

  @override
  String toString() => 'TimerRunInProgress { duration: $duration }';
}

/// 定时器完成时
final class TimerRunComplete extends TimerState {
  const TimerRunComplete() : super(0);
}
