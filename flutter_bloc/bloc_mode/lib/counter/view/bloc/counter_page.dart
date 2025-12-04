import 'package:bloc_mode/counter/bloc/counter_bloc.dart';
import 'package:bloc_mode/core/di/injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/counter_event.dart';
import 'counter_view.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => injector<CounterBloc>()..add(const IncrementCountEvent()),
      child: const CounterView(),
    );
  }
}
