import 'package:provider_mode/core/utils/same_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class KeyValueDb {
  Future<void> init();

  T get<T>(String key, T defaultValue);

  Future<void> put<T>(String key, T value);
}

class SharedPreferencesDb implements KeyValueDb {
  late final SharedPreferences _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  T get<T>(String key, T defaultValue) {
    try {
      if (sameTypes<T, String>()) {
        final value = _prefs.getString(key) ?? defaultValue as String;
        return value as T;
      }
    } catch (e) {
      return defaultValue;
    }
    return defaultValue;
  }

  @override
  Future<void> put<T>(String key, T value) async {
    // await _prefs.setInt(key, value);
  }
}
