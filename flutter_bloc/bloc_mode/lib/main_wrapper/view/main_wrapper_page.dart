import 'package:bloc_mode/main_wrapper/view/main_wrapper_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../counter/bloc/counter_bloc.dart';
import '../../counter/cubit/counter_cubit.dart';
import '../../di/injector.dart';
import '../../timer/bloc/timer_bloc.dart';

class MainWrapperPage extends StatelessWidget {
  const MainWrapperPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers:  [
        BlocProvider(create: (_) => injector<CounterBloc>()),
        BlocProvider(create: (_) => injector<CounterCubit>()),
        BlocProvider(create: (_) => injector<TimerBloc>()),
      ],
      child: MainWrapperView(navigationShell: navigationShell),
    );
  }
}
