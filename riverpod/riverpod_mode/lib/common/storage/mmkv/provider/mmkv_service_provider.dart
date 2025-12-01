import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_mode/common/storage/mmkv/mmkv_service.dart';

part 'mmkv_service_provider.g.dart';

@riverpod
MMKVService mmkvService(Ref ref) {
  return MMKVService();
}
