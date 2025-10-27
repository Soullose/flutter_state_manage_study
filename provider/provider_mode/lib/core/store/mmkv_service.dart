import 'package:flutter/foundation.dart';
import 'package:mmkv/mmkv.dart';
import 'package:provider_mode/core/utils/same_types.dart';

import 'key_value_db.dart';

class MMKVService implements KeyValueDb {
  static final MMKVService _instance = MMKVService._internal();

  factory MMKVService() => _instance;

  MMKVService._internal();

  late final MMKV _mmkv;

  @override
  Future<void> init() async {
    try {
      await MMKV.initialize();
      _mmkv = MMKV.defaultMMKV();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Future<void> put<T>(String key, T value) async {
    try {
      if (sameTypes<T, int>()) {
        _mmkv.encodeInt(key, value as int);
      }
      if (sameTypes<T, double>()) {
        _mmkv.encodeDouble(key, value as double);
      }
      if (sameTypes<T, bool>()) {
        _mmkv.encodeBool(key, value as bool);
      }
      if (sameTypes<T, String>()) {
        _mmkv.encodeString(key, value as String);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  T get<T>(String key, T defaultValue) {
    try {
      if (sameTypes<T, int>()) {
        final value = _mmkv.decodeInt(key);
        return value as T;
      }
      if (sameTypes<T, double>()) {
        final value = _mmkv.decodeDouble(key);
        return value as T;
      }
      if (sameTypes<T, bool>()) {
        final value = _mmkv.decodeBool(key);
        return value as T;
      }
      if (sameTypes<T, String>()) {
        final value = _mmkv.decodeString(key);
        return value as T;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return defaultValue;
    }
    return defaultValue;
  }
}
