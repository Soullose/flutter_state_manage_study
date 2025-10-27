import 'package:flutter/foundation.dart';
import 'package:provider_mode/core/store/shared_preferences_service.dart';
import 'package:provider_mode/di/injector.dart';

import '../core/store/key_value_db.dart';

class CounterProvider with ChangeNotifier, DiagnosticableTreeMixin {
  final KeyValueDb _db = injector<SharedPreferencesDb>(); // 保存实例引用
  int _count = 0;

  int get count => _db.get('count', 0);

  void increment() {
    // _count++;
    _count = count + 1; // 先获取当前值并加1
    _db.put<int>('count', _count);
    notifyListeners();
  }

  /// 调试用
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('count', count));
  }
}
