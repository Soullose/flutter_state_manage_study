import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_setting.freezed.dart';

@freezed
abstract class BaseSetting with _$BaseSetting {
  const factory BaseSetting({required String ipAddress}) = _BaseSetting;
}
