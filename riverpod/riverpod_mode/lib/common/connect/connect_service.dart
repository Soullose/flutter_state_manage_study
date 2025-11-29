import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connect_service.g.dart';

@Riverpod(keepAlive: true)
Connectivity connectivity(Ref ref) {
  return Connectivity();
}

@Riverpod(keepAlive: true)
Stream<List<ConnectivityResult>> connectivityState(Ref ref) {
  /// 使用缓存的Connectivity实例，避免重复创建
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.onConnectivityChanged;
}

@Riverpod(keepAlive: true)
void connectivityListener(Ref ref) {
  print('xxxxxxxxxxxxxxxxxxxx');
  ref.listen(connectivityStateProvider, (previous, next) {
    print('${next.value}');
    if (previous != next) {
      if (kDebugMode) {
        print('WiFi status changed: $next');
      }
      // 这里添加业务逻辑，如更新UI或状态
    }
  });
}
