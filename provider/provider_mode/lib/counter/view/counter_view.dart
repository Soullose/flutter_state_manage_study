import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../counter_provider.dart';

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习Provider状态管理'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:'),
            Count(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('increment_floatingActionButton'),
        onPressed: () => context.read<CounterProvider>().increment(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
class Count extends StatelessWidget {
  const Count({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final count = Provider.of<CounterProvider>(context);
    return Text(
      /// Calls `context.watch` to make [Count] rebuild when [Counter] changes.
      '${context.watch<CounterProvider>().count}',
      key: const Key('counterState'),
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}