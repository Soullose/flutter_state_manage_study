import 'package:provider_mode/core/utils/same_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class KeyValueDb {
  Future<void> init();

  T get<T>(String key, T defaultValue);

  Future<void> put<T>(String key, T value);
}

class SharedPreferencesDb implements KeyValueDb {
  static final SharedPreferencesDb _instance = SharedPreferencesDb._internal();
  factory SharedPreferencesDb() => _instance;
  SharedPreferencesDb._internal();
  late final SharedPreferences _prefs;

  @override
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      throw Exception('Failed to initialize SharedPreferences: $e');
    }
  }

  @override
  T get<T>(String key, T defaultValue) {
    try {
      if (sameTypes<T, String>()) {
        final value = _prefs.getString(key) ?? defaultValue as String;
        return value as T;
      }
      if (sameTypes<T, int>()) {
        final value = _prefs.getInt(key) ?? defaultValue as int;
        return value as T;
      }
      if (sameTypes<T, bool>()) {
        final value = _prefs.getBool(key) ?? defaultValue as bool;
        return value as T;
      }
      if (sameTypes<T, double>()) {
        final value = _prefs.getDouble(key) ?? defaultValue as double;
        return value as T;
      }
      if (sameTypes<T, List<String>>()) {
        final value = _prefs.getStringList(key) ?? defaultValue as List<String>;
        return value as T;
      }
    } catch (e) {
      return defaultValue;
    }
    return defaultValue;
  }

  @override
  Future<void> put<T>(String key, T value) async {
    if (sameTypes<T, int>()) {
      await _prefs.setInt(key, value as int);
    }
    if (sameTypes<T, String>()) {
      await _prefs.setString(key, value as String);
    }
    if (sameTypes<T, bool>()) {
      await _prefs.setBool(key, value as bool);
    }
    if (sameTypes<T, double>()) {
      await _prefs.setDouble(key, value as double);
    }
    if (sameTypes<T, List<String>>()) {
      await _prefs.setStringList(key, value as List<String>);
    }
    return;
  }
}
