import 'dart:convert';

import 'package:bloc_mode/core/utils/same_types.dart';
import 'package:mmkv/mmkv.dart';

/// 键值存储抽象接口
///
/// 定义了键值存储的基本操作，支持泛型的获取和存储。
/// 实现类可以是 SharedPreferences、MMKV 或其他存储方案。
abstract class KeyValueDb {
  /// 初始化存储服务
  ///
  /// 在使用存储服务前必须调用此方法进行初始化。
  /// 抛出 [Exception] 如果初始化失败。
  Future<void> init();

  /// 获取指定键的值
  ///
  /// [key] - 键名
  /// [defaultValue] - 默认值，当键不存在或类型不匹配时返回
  /// 返回存储的值或默认值
  T get<T>(String key, T defaultValue);

  /// 存储指定键的值
  ///
  /// [key] - 键名
  /// [value] - 要存储的值
  /// 支持的类型：String, int, bool, double, List<String>
  Future<void> put<T>(String key, T value);
}

/// 基于 MMKV 的键值存储服务实现
///
/// MMKV 是腾讯开源的高性能键值存储组件，比 SharedPreferences 更高效。
/// 支持的数据类型：String, int, bool, double, List<String>
///
/// 使用示例：
/// ```dart
/// final mmkvDb = MmkvDb();
/// await mmkvDb.init();
/// mmkvDb.put('username', 'John');
/// final name = mmkvDb.get('username', '');
/// ```
class MmkvDb implements KeyValueDb {
  /// 单例实例
  static final MmkvDb _instance = MmkvDb._internal();

  /// 获取单例实例
  factory MmkvDb() => _instance;

  /// 私有构造函数
  MmkvDb._internal();

  /// MMKV 实例
  late final MMKV _mmkv;

  /// 是否已初始化
  bool _initialized = false;

  /// 检查是否已初始化
  bool get isInitialized => _initialized;

  @override
  Future<void> init() async {
    if (_initialized) return;

    try {
      // MMKV.initialize() 应该在 main.dart 中调用
      // 这里只获取默认实例
      _mmkv = MMKV.defaultMMKV();
      _initialized = true;
    } catch (e) {
      throw Exception('Failed to initialize MMKV: $e');
    }
  }

  @override
  T get<T>(String key, T defaultValue) {
    try {
      if (sameTypes<T, String>()) {
        final value = _mmkv.decodeString(key);
        return (value ?? defaultValue as String) as T;
      }
      if (sameTypes<T, int>()) {
        final value = _mmkv.decodeInt(key, defaultValue: defaultValue as int);
        return value as T;
      }
      if (sameTypes<T, bool>()) {
        final value = _mmkv.decodeBool(key, defaultValue: defaultValue as bool);
        return value as T;
      }
      if (sameTypes<T, double>()) {
        final value = _mmkv.decodeDouble(
          key,
          defaultValue: defaultValue as double,
        );
        return value as T;
      }
      if (sameTypes<T, List<String>>()) {
        final value = _decodeStringList(key);
        if (value != null) {
          return value as T;
        }
        return defaultValue;
      }
    } catch (e) {
      return defaultValue;
    }
    return defaultValue;
  }

  @override
  Future<void> put<T>(String key, T value) async {
    if (sameTypes<T, int>()) {
      _mmkv.encodeInt(key, value as int);
    }
    if (sameTypes<T, String>()) {
      _mmkv.encodeString(key, value as String);
    }
    if (sameTypes<T, bool>()) {
      _mmkv.encodeBool(key, value as bool);
    }
    if (sameTypes<T, double>()) {
      _mmkv.encodeDouble(key, value as double);
    }
    if (sameTypes<T, List<String>>()) {
      _encodeStringList(key, value as List<String>);
    }
    return;
  }

  /// 编码 List<String> 为 JSON 字符串存储
  ///
  /// MMKV 不直接支持 List<String>，需要转换为 JSON 字符串
  bool _encodeStringList(String key, List<String> value) {
    final jsonString = jsonEncode(value);
    return _mmkv.encodeString(key, jsonString);
  }

  /// 从 JSON 字符串解码 List<String>
  ///
  /// MMKV 不直接支持 List<String>，需要从 JSON 字符串解码
  List<String>? _decodeStringList(String key) {
    final jsonString = _mmkv.decodeString(key);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.cast<String>();
    } catch (e) {
      return null;
    }
  }

  /// 删除指定键
  ///
  /// [key] - 要删除的键名
  void remove(String key) {
    _mmkv.removeValue(key);
  }

  /// 检查是否包含指定键
  ///
  /// [key] - 键名
  /// 返回是否包含该键
  bool containsKey(String key) {
    return _mmkv.containsKey(key);
  }

  /// 获取所有键
  ///
  /// 返回所有存储的键名列表
  List<String> getAllKeys() {
    return _mmkv.allKeys;
  }

  /// 清除所有数据
  ///
  /// 警告：此操作将删除所有存储的数据
  void clearAll() {
    _mmkv.clearAll();
  }
}
