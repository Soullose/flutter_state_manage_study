import 'package:flutter/foundation.dart';
import 'package:provider_mode/core/store/key_value_db.dart';
import 'package:provider_mode/core/store/mmkv_service.dart';
import 'package:provider_mode/core/store/shared_preferences_service.dart';
import 'package:provider_mode/di/injector.dart';


class CounterProvider with ChangeNotifier, DiagnosticableTreeMixin {
  final KeyValueDb _db = injector<SharedPreferencesDb>(); // 保存实例引用
  final KeyValueDb _mmkv = injector<MMKVService>();
  int _count = 0;

  int get count => _db.get('count', 0);

  int get count1 => _mmkv.get('count', 0);
  void increment() {
    // _count++;
    _count = count + 1; // 先获取当前值并加1
    _db.put<int>('count', _count);
    _mmkv.put('count', _count);
    notifyListeners();
  }

  /// 调试用
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('count', count));
  }
}
