import 'package:flutter/foundation.dart';

class CounterProvider with ChangeNotifier, DiagnosticableTreeMixin {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    print(_count);
    notifyListeners();
  }

  /// 调试用
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('count', count));
  }
}
