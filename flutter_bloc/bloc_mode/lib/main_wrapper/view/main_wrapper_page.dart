import 'package:bloc_mode/common/di/injector.dart';
import 'package:bloc_mode/counter/bloc/counter_bloc.dart';
import 'package:bloc_mode/counter/cubit/counter_cubit.dart';
import 'package:bloc_mode/main_wrapper/main_wrapper_bloc.dart';
import 'package:bloc_mode/main_wrapper/view/main_wrapper_view.dart';
import 'package:bloc_mode/timer/bloc/timer_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MainWrapperPage extends StatelessWidget {
  const MainWrapperPage(
      {required this.navigationShell,
        // required this.children,
        Key? key})
      : super(key: key ?? const ValueKey<String>('MainWrapperPage'));

  final StatefulNavigationShell navigationShell;
  // final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => injector<MainWrapperBloc>()),
        BlocProvider(create: (_) => injector<CounterBloc>()),
        BlocProvider(create: (_) => injector<CounterCubit>()),
        BlocProvider(create: (_) => injector<TimerBloc>()),
      ],
      child:
          MainWrapperView(navigationShell: navigationShell),
    );
  }
}
