import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_mode/counter/counter_provider.dart';
import 'package:provider_mode/di/injector.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final count = Provider.of<CounterProvider>(context);
    ChangeNotifierProvider.value(value: value)
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习Provider状态管理'),
        centerTitle: true,
      ),
      body:
      const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:'),

            /// Extracted as a separate widget for performance optimization.
            /// As a separate widget, it will rebuild independently from [MyHomePage].
            ///
            /// This is totally optional (and rarely needed).
            /// Similarly, we could also use [Consumer] or [Selector].
            Count(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('increment_floatingActionButton'),

        /// Calls `context.read` instead of `context.watch` so that it does not rebuild
        /// when [Counter] changes.
        onPressed: () => count.increment(),
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
    final count = Provider.of<CounterProvider>(context);
    return Text(
      /// Calls `context.watch` to make [Count] rebuild when [Counter] changes.
      '${count.count}',
      key: const Key('counterState'),
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}