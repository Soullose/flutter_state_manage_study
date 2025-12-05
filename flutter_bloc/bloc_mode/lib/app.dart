import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('学习Bloc'),
        // .animate()
        // .fade(duration: 500.ms)
        // .scale(delay: 300.ms)
        // .move(
        //     delay: 300.ms,
        //     duration: 600.ms) ,// runs after the above w/new duration
        // .blurXY(),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => context.go('/one/blocCount'),
              child: const Text('Bloc模式的加减数'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/one/cubitCount'),
              child: const Text('Cubit模式的加减数'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/one/blocTimer'),
              child: const Text('Bloc定时器'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/one/blocMqtt'),
              child: const Text('Bloc-Mqtt连接'),
            ),
          ],
        ),
      ),
    );
  }
}
