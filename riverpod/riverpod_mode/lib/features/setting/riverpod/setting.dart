import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_mode/common/storage/shared_preferences_service.dart';
import 'package:riverpod_mode/features/setting/model/base_setting.dart';

part 'setting.g.dart';

@riverpod
class Setting extends _$Setting {
  @override
  Future<BaseSetting> build() async {
    final prefs = await ref.watch(sharedPreferencesServiceProvider.future);
    if (kDebugMode) {
      print('ip: ${prefs.getString("ipAddress")}');
    }
    return BaseSetting(
      ipAddress: prefs.getString("ipAddress") ?? "192.168.0.1",
      apiBaseUrl:
          prefs.getString("apiBaseUrl") ?? "https://api.openai.com",
      apiKey: prefs.getString("apiKey") ?? "",
      apiModel: prefs.getString("apiModel") ?? "gpt-3.5-turbo",
      useMock: prefs.getBool("useMock") ?? true,
    );
  }

  Future<void> setIpAddress(String ipAddress) async {
    if (kDebugMode) {
      print('ipAddress:$ipAddress');
    }
    final prefs = await ref.watch(sharedPreferencesServiceProvider.future);
    prefs.setString("ipAddress", ipAddress);
    _emit((current) => current.copyWith(ipAddress: ipAddress));
  }

  Future<void> setApiBaseUrl(String apiBaseUrl) async {
    final prefs = await ref.watch(sharedPreferencesServiceProvider.future);
    prefs.setString("apiBaseUrl", apiBaseUrl);
    _emit((current) => current.copyWith(apiBaseUrl: apiBaseUrl));
  }

  Future<void> setApiKey(String apiKey) async {
    final prefs = await ref.watch(sharedPreferencesServiceProvider.future);
    prefs.setString("apiKey", apiKey);
    _emit((current) => current.copyWith(apiKey: apiKey));
  }

  Future<void> setApiModel(String apiModel) async {
    final prefs = await ref.watch(sharedPreferencesServiceProvider.future);
    prefs.setString("apiModel", apiModel);
    _emit((current) => current.copyWith(apiModel: apiModel));
  }

  Future<void> setUseMock(bool useMock) async {
    final prefs = await ref.watch(sharedPreferencesServiceProvider.future);
    prefs.setBool("useMock", useMock);
    _emit((current) => current.copyWith(useMock: useMock));
  }

  /// 在当前 state 基础上应用更新并重新发射
  void _emit(BaseSetting Function(BaseSetting current) updater) {
    final value = state.value;
    if (value == null) return;
    state = AsyncValue.data(updater(value));
  }
}
