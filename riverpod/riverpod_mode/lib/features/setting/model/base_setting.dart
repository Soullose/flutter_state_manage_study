import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_setting.freezed.dart';

@freezed
abstract class BaseSetting with _$BaseSetting {
  const factory BaseSetting({
    /// 服务地址（通用网络配置）
    required String ipAddress,

    /// AI 服务 BaseUrl（OpenAI 兼容接口地址，如 https://api.openai.com）
    @Default('https://api.openai.com') String apiBaseUrl,

    /// AI 服务 API Key
    @Default('') String apiKey,

    /// AI 模型名称（如 gpt-3.5-turbo）
    @Default('gpt-3.5-turbo') String apiModel,

    /// 是否使用 Mock 数据源（true 时无需后端和 API Key，开箱即用）
    @Default(true) bool useMock,
  }) = _BaseSetting;
}
