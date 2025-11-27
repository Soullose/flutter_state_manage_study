import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Useful to log state change in our application
/// Read the logs and you'll better understand what's going on under the hood
final class StateLogger extends ProviderObserver {
  const StateLogger();

  @override
  Future<void> didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) async {
    if (kDebugMode) {
      print(
        'PROVIDER    : ${context.provider.name ?? '<NO NAME>'}\n'
        '  Type      : ${context.runtimeType}\n'
        '  Old value : $previousValue\n'
        '  New value : $newValue',
      );
    }
    super.didUpdateProvider(context, previousValue, newValue);
  }
}
