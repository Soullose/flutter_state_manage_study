import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_mode/common/storage/shared_preferences_service.dart';
import 'package:riverpod_mode/pages/setting/model/base_setting.dart';

part 'setting.g.dart';

@riverpod
class Setting extends _$Setting {
  @override
  Future<BaseSetting> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    // ipAddress = prefs.getString("ipAddress") ?? "192.168.0.1";
    return BaseSetting(ipAddress: prefs.getString("ipAddress") ?? "192.168.0.1");
  }

  Future<void> setIpAddress(String ipAddress) async {
    print('ipAddress:$ipAddress');
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    state = AsyncValue.data(BaseSetting(ipAddress: ipAddress));
    prefs.setString("ipAddress", ipAddress);
    print('xxxx:${prefs.getString("ipAddress")}');
  }
}
