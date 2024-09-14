import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_mode/counter/counter_provider.dart';
import 'package:provider_mode/counter/view/counter_view.dart';
import 'package:provider_mode/di/injector.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => injector<CounterProvider>(),
      child: const CounterView(),
    );
  }
}
