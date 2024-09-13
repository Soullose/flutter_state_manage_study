part of 'timer_bloc.dart';

@immutable
sealed class TimerState extends Equatable {
  const TimerState(this.duration);

  final int duration;

  @override
  List<Object> get props => [duration];
}

/// 定时器初始值
final class TimerInitial extends TimerState {
  const TimerInitial(super.duration);

  @override
  List<Object> get props => [duration];

  @override
  String toString() {
    return 'TimerInitial { duration: $duration }';
  }
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
