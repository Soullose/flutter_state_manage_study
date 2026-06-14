import 'package:flutter_test/flutter_test.dart';
import 'package:provider_mode/core/store/key_value_db.dart';
import 'package:provider_mode/features/counter/counter_provider.dart';

/// Mock KeyValueDb 用于测试
class MockKeyValueDb implements KeyValueDb {
  final Map<String, dynamic> _store = {};

  @override
  Future<void> init() async {}

  @override
  T get<T>(String key, T defaultValue) {
    return _store[key] as T? ?? defaultValue;
  }

  @override
  Future<void> put<T>(String key, T value) async {
    _store[key] = value;
  }
}

void main() {
  late CounterProvider counterProvider;
  late MockKeyValueDb mockDb;

  setUp(() {
    mockDb = MockKeyValueDb();
    counterProvider = CounterProvider(sharedPreferencesDb: mockDb);
  });

  group('CounterProvider', () {
    test('初始计数应为 0', () {
      expect(counterProvider.count, 0);
    });

    test('increment 应增加计数', () {
      counterProvider.increment();
      expect(counterProvider.count, 1);
    });

    test('多次 increment 应正确累加', () {
      counterProvider.increment();
      counterProvider.increment();
      counterProvider.increment();
      expect(counterProvider.count, 3);
    });

    test('decrement 应减少计数', () {
      counterProvider.increment();
      counterProvider.increment();
      counterProvider.decrement();
      expect(counterProvider.count, 1);
    });

    test('decrement 允许负数', () {
      counterProvider.decrement();
      expect(counterProvider.count, -1);
    });

    test('reset 应重置计数为 0', () {
      counterProvider.increment();
      counterProvider.increment();
      counterProvider.reset();
      expect(counterProvider.count, 0);
    });

    test('increment 应触发 notifyListeners', () {
      var notified = false;
      counterProvider.addListener(() {
        notified = true;
      });

      counterProvider.increment();
      expect(notified, isTrue);
    });

    test('状态应持久化到 KeyValueDb', () {
      counterProvider.increment();
      counterProvider.increment();

      // 创建新实例模拟重启
      final newProvider = CounterProvider(sharedPreferencesDb: mockDb);
      expect(newProvider.count, 2);
    });
  });
}
