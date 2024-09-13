import 'package:bloc_mode/di/injector.dart';
import 'package:bloc_mode/timer/bloc/timer_bloc.dart';
import 'package:bloc_mode/timer/view/timer_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => injector<TimerBloc>(),
      child: const TimerView(),
    );
  }
}
