import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider_mode/counter/counter_provider.dart';
import 'package:provider_mode/di/injector.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    // final count = Provider.of<CounterProvider>(context);
    // ChangeNotifierProvider.value(value: value)
    return Scaffold(
        appBar: AppBar(
          title: const Text('学习Provider状态管理'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Text('You have pushed the button this many times:'),
              ElevatedButton(
                onPressed: () => context.go('/providerCounter'),
                child: const Text('Provider计数器'),
              ),
            ],
          ),
        ),
    );
  }
}
