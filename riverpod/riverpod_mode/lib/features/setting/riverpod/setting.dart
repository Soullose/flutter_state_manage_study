import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_mode/common/storage/shared_preferences_service.dart';
import 'package:riverpod_mode/features/setting/model/base_setting.dart';

part 'setting.g.dart';

@riverpod
class Setting extends _$Setting {
  @override
  Future<BaseSetting> build() async {
    final xx = await ref.read(sharedPreferencesServiceProvider.future);
    if (kDebugMode) {
      print('ip: ${xx.getString("ipAddress")}');
    }
    final prefs = await ref.watch(sharedPreferencesServiceProvider.future);
    // ipAddress = prefs.getString("ipAddress") ?? "192.168.0.1";
    return BaseSetting(
        ipAddress: prefs.getString("ipAddress") ?? "192.168.0.1");
  }

  Future<void> setIpAddress(String ipAddress) async {
    if (kDebugMode) {
      print('ipAddress:$ipAddress');
    }
    final prefs = await ref.watch(sharedPreferencesServiceProvider.future);
    state = AsyncValue.data(BaseSetting(ipAddress: ipAddress));
    prefs.setString("ipAddress", ipAddress);
    if (kDebugMode) {
      print('xxxx:${prefs.getString("ipAddress")}');
    }
  }
}
