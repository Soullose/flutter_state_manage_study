import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_mode/features/timer/state/timer_state.dart';

part 'timer_controller.g.dart';

@riverpod
class TimerController extends _$TimerController {
  final int _duration = 10;
  final Ticker _ticker = const Ticker();

  StreamSubscription<int>? _tickerSubscription;

  @override
  Stream<TimerState> build() {
    ref.onDispose(() {
      if (kDebugMode) {
        print('[timerProvider] disposed');
      }
      _tickerSubscription?.cancel();
    });
    return Stream.value(TimeStateInitial(_duration));
  }

  void startTimer() {
    state = AsyncData(TimerRunInProgress(_duration));
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker.tick(ticks: _duration).listen((duration) {
      state = duration > 0
          ? AsyncData(TimerRunInProgress(duration))
          : const AsyncData(TimerRunComplete());
    });
  }

  void pauseTimer() {
    // nullable
    switch (state.value!) {
    // pattern matching
      case TimerRunInProgress(:int duration):
        _tickerSubscription?.pause();
        state = AsyncData(TimerRunPause(duration));
      case _:
    }
  }

  void resumeTimer() {
    switch (state.value!) {
    // pattern matching
      case TimerRunPause(:int duration):
        _tickerSubscription?.resume();
        state = AsyncData(TimerRunInProgress(duration));
      case _:
    }
  }

  void resetTimer() {
    _tickerSubscription?.cancel();
    state = AsyncData(TimeStateInitial(_duration));
  }

}

class Ticker {
  const Ticker();

  Stream<int> tick({required int ticks}) {
    return Stream.periodic(const Duration(seconds: 1), (x) => ticks - x - 1)
        .take(ticks);
  }
}
