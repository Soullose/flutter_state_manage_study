import 'package:bloc_mode/counter/cubit/counter_cubit.dart';
import 'package:bloc_mode/counter/view/cubit/count/counter_cubit_view.dart';
import 'package:bloc_mode/di/injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterCubitPage extends StatelessWidget {
  const CounterCubitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => injector<CounterCubit>(),
      child: const CounterCubitView(),
    );
  }
}
