import 'dart:async';

import 'package:material_ui/material_ui.dart';

/// 用于监听 Bloc 状态变化并触发 GoRouter 刷新
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
