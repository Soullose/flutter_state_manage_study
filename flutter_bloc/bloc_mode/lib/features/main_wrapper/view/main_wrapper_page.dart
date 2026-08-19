import 'package:bloc_mode/core/di/injector.dart';
import 'package:bloc_mode/features/counter/bloc/counter_bloc.dart';
import 'package:bloc_mode/features/counter/cubit/counter_cubit.dart';
import 'package:bloc_mode/features/main_wrapper/main_wrapper_bloc.dart';
import 'package:bloc_mode/features/main_wrapper/view/main_wrapper_view.dart';
import 'package:bloc_mode/features/timer/bloc/timer_bloc.dart';
import 'package:material_ui/material_ui.dart';
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
