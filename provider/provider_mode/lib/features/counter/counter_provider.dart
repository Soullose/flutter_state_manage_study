import 'package:flutter/foundation.dart';
import 'package:provider_mode/core/store/key_value_db.dart';

/// 计数器状态管理 Provider
///
/// 展示 Provider 基础用法：ChangeNotifier + 构造注入 + 持久化存储
class CounterProvider with ChangeNotifier, DiagnosticableTreeMixin {
  final KeyValueDb _db;

  int _count = 0;

  CounterProvider({
    required KeyValueDb sharedPreferencesDb,
    @Deprecated('仅用于学习对比，生产环境请只使用一种存储') KeyValueDb? mmkvService,
  }) : _db = sharedPreferencesDb {
    _count = _db.get('count', 0);
  }

  int get count => _count;

  void increment() {
    _count++;
    _db.put<int>('count', _count);
    notifyListeners();
  }

  void decrement() {
    _count--;
    _db.put<int>('count', _count);
    notifyListeners();
  }

  void reset() {
    _count = 0;
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
