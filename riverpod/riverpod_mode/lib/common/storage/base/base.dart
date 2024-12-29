import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_mode/common/storage/shared_preferences_provider.dart';

part 'base.g.dart';

@riverpod
Future<String?> token(Ref ref) {
  final sharedPreferencesUtils = ref.read(sharedPreferencesUtilsProvider);
  return sharedPreferencesUtils.value!.getStringAsync('token');
}

@riverpod
Future<List<String>?> cookie(Ref ref) {
  final sharedPreferencesUtils = ref.read(sharedPreferencesUtilsProvider);
  return sharedPreferencesUtils.value!.getListAsync('cookie');
}