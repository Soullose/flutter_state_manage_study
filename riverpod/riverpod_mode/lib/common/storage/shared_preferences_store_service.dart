import 'package:shared_preferences/shared_preferences.dart';

abstract class SharedPreferencesAsync {
  Future<bool> setInt(String key, int value);

  Future<bool> setBool(String key, bool value);

  Future<bool> setString(String key, String value);

  Future<bool> setList(String key, List<String> value);

  Future<int?> getInt(String key);

  Future<bool?> getBool(String key);

  Future<String?> getString(String key);

  Future<List<String>?> getList(String key);

  Future<void> remove(String key);
}

class SharedPreferencesAsyncImpl implements SharedPreferencesAsync {
  final SharedPreferences prefs;

  SharedPreferencesAsyncImpl({required this.prefs});

  @override
  Future<bool?> getBool(String key) {
    // TODO: implement getBool
    throw UnimplementedError();
  }

  @override
  Future<int?> getInt(String key) {
    // TODO: implement getInt
    throw UnimplementedError();
  }

  @override
  Future<List<String>?> getList(String key) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future<String?> getString(String key) {
    // TODO: implement getString
    throw UnimplementedError();
  }

  @override
  Future<void> remove(String key) {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  Future<bool> setBool(String key, bool value) {
    // TODO: implement setBool
    throw UnimplementedError();
  }

  @override
  Future<bool> setInt(String key, int value) {
    // TODO: implement setInt
    throw UnimplementedError();
  }

  @override
  Future<bool> setList(String key, List<String> value) {
    // TODO: implement setList
    throw UnimplementedError();
  }

  @override
  Future<bool> setString(String key, String value) {
    // TODO: implement setString
    throw UnimplementedError();
  }
}
