import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';



@riverpod
Future<SharedPreferencesUtils> sharedPreferencesUtils (Ref ref) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  return SharedPreferencesUtils(prefs: prefs, asyncPrefs: asyncPrefs);
}

class SharedPreferencesUtils {
  final SharedPreferences prefs;
  final SharedPreferencesAsync asyncPrefs;

  SharedPreferencesUtils({required this.prefs, required this.asyncPrefs});

  Future<bool> setInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }

  Future<bool> setBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  Future<bool> setDouble(String key, double value) async {
    return await prefs.setDouble(key, value);
  }

  Future<bool> setString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  Future<bool> setList(String key, List<String> value) async {
    return await prefs.setStringList(key, value);
  }

  int? getInt(String key) {
    return prefs.getInt(key);
  }

  bool? getBool(String key) {
    return prefs.getBool(key);
  }

  double? getDouble(String key) {
    return prefs.getDouble(key);
  }

  String? getString(String key) {
    return prefs.getString(key);
  }

  List<String>? getList(String key) {
    return prefs.getStringList(key);
  }

  Future<void> setIntAsync(String key, int value) async {
    return await asyncPrefs.setInt(key, value);
  }

  Future<void> setBoolAsync(String key, bool value) async {
    return await asyncPrefs.setBool(key, value);
  }

  Future<void> setDoubleAsync(String key, double value) async {
    return await asyncPrefs.setDouble(key, value);
  }

  Future<void> setStringAsync(String key, String value) async {
    return await asyncPrefs.setString(key, value);
  }

  Future<void> setListAsync(String key, List<String> value) async {
    return await asyncPrefs.setStringList(key, value);
  }

  Future<int?> getIntAsync(String key) async {
    return await asyncPrefs.getInt(key);
  }

  Future<bool?> getBoolAsync(String key) async {
    return asyncPrefs.getBool(key);
  }

  Future<double?> getDoubleAsync(String key) async {
    return asyncPrefs.getDouble(key);
  }

  Future<String?> getStringAsync(String key) async {
    return asyncPrefs.getString(key);
  }

  Future<List<String>?> getListAsync(String key) async {
    return asyncPrefs.getStringList(key);
  }

  Future<void> removeAsync(String key) async {
    return await asyncPrefs.remove(key);
  }

  Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }
}
