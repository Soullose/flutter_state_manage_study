import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/counter_provider.dart';

class CounterPage extends ConsumerWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int count = ref.watch(counterProvider.select((count) => count));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'hero_/riverpodCounter',
              flightShuttleBuilder: _flightShuttleBuilder,
              child: const Icon(Icons.add_circle_outline),
            ),
            const SizedBox(width: 8),
            const Text('Counter example'),
          ],
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primaryContainer,
                border: Border.all(color: colorScheme.primary, width: 3),
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '点击右下角按钮增加计数',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'counter_fab',
        onPressed: () async {
          ref.read(counterProvider.notifier).increment();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  static Widget _flightShuttleBuilder(
    BuildContext context,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return Icon(
      Icons.add_circle_outline,
      size: 24,
      color: Theme.of(fromHeroContext).colorScheme.onSurface,
    );
  }
}
