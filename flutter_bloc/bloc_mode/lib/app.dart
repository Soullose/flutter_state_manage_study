import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习Flutter'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => context.go('/blocCount'),
              child: const Text('Bloc模式的加减数'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/cubitCount'),
              child: const Text('Cubit模式的加减数'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/blocTimer'),
              child: const Text('Bloc定时器'),
            ),
          ],
        ),
      ),
    );
  }
}
