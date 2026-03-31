import 'dart:convert';

import 'package:mmkv/mmkv.dart';

/// MMKV 工具类 - 提供类型安全的键值存储操作
///
/// MMKV 是腾讯开源的高性能键值存储组件，比 SharedPreferences 更高效。
/// 所有操作都是同步的，无需 await。
///
/// 使用示例：
/// ```dart
/// final mmkv = MmkvUtils();
/// mmkv.setString('username', 'John');
/// final name = mmkv.getString('username');
/// ```
class MmkvUtils {
  /// MMKV 实例
  final MMKV _mmkv;

  /// 构造函数
  ///
  /// [mmkv] - 可选的 MMKV 实例，如果不提供则使用默认实例
  MmkvUtils({MMKV? mmkv}) : _mmkv = mmkv ?? MMKV.defaultMMKV();

  /// 存储int 值
  ///
  /// [key] - 键名
  /// [value] - int 值
  /// 返回是否存储成功
  bool setInt(String key, int value) {
    return _mmkv.encodeInt(key, value);
  }

  /// 获取 int 值
  ///
  /// [key] - 键名
  /// 返回存储的 int 值，如果不存在返回 null
  int? getInt(String key) {
    if (!_mmkv.containsKey(key)) return null;
    return _mmkv.decodeInt(key);
  }

  /// 存储 bool 值
  ///
  /// [key] - 键名
  /// [value] - bool 值
  /// 返回是否存储成功
  bool setBool(String key, bool value) {
    return _mmkv.encodeBool(key, value);
  }

  /// 获取 bool 值
  ///
  /// [key] - 键名
  /// 返回存储的 bool 值，如果不存在返回 null
  bool? getBool(String key) {
    if (!_mmkv.containsKey(key)) return null;
    return _mmkv.decodeBool(key);
  }

  /// 存储 double 值
  ///
  /// [key] - 键名
  /// [value] - double 值
  /// 返回是否存储成功
  bool setDouble(String key, double value) {
    return _mmkv.encodeDouble(key, value);
  }

  /// 获取 double 值
  ///
  /// [key] - 键名
  /// 返回存储的 double 值，如果不存在返回 null
  double? getDouble(String key) {
    if (!_mmkv.containsKey(key)) return null;
    return _mmkv.decodeDouble(key);
  }

  /// 存储 String 值
  ///
  /// [key] - 键名
  /// [value] - String 值
  /// 返回是否存储成功
  bool setString(String key, String value) {
    return _mmkv.encodeString(key, value);
  }

  /// 获取 String 值
  ///
  /// [key] - 键名
  /// 返回存储的 String 值，如果不存在返回 null
  String? getString(String key) {
    return _mmkv.decodeString(key);
  }

  /// 存储 List<String> 值
  ///
  /// [key] - 键名
  /// [value] - List<String> 值
  /// 返回是否存储成功
  bool setList(String key, List<String> value) {
    // 将 List<String> 编码为 JSON 字符串存储
    final jsonString = jsonEncode(value);
    return _mmkv.encodeString(key, jsonString);
  }

  /// 获取 List<String> 值
  ///
  /// [key] - 键名
  /// 返回存储的 List<String> 值，如果不存在返回 null
  List<String>? getList(String key) {
    final jsonString = _mmkv.decodeString(key);
    if (jsonString == null) return null;

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<String>();
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
