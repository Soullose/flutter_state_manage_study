import 'package:flutter/material.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习Flutter'),
        centerTitle: true,
        elevation: 1.0,
        shadowColor: Theme.of(context).colorScheme.shadow,
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => {},
              child: const Text('Bloc模式的加减数'),
            ),
            ElevatedButton(
              onPressed: () => {},
              child: const Text('Cubit模式的加减数'),
            ),
            ElevatedButton(
              onPressed: () => {},
              child: const Text('Bloc定时器'),
            ),
          ],
        ),
      ),
    );
  }
}
