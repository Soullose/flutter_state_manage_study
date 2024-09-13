import 'package:bloc_mode/counter/bloc/counter_bloc.dart';
import 'package:bloc_mode/counter/bloc/counter_event.dart';
import 'package:bloc_mode/counter/bloc/counter_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Flutter Bloc Counter Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              BlocBuilder<CounterBloc, CounterState>(builder: (context, state) {
                return Text("点击了${state.counter}次");
              }),
              // Text(
              //   '$_counter',
              //   style: Theme.of(context).textTheme.headlineMedium,
              // ),
            ],
          ),
        ),
        floatingActionButton:
            BlocBuilder<CounterBloc, CounterState>(builder: (context, state) {
          return FloatingActionButton(
            onPressed: () {
              context.read<CounterBloc>().add(const IncrementCountEvent());
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          );
        }) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
