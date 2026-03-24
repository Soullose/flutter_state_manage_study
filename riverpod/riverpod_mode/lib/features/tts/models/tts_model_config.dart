import 'package:freezed_annotation/freezed_annotation.dart';

part 'tts_model_config.freezed.dart';
part 'tts_model_config.g.dart';

/// TTS 模型来源类型
enum TtsModelSource {
  /// 预置在 assets 中的模型
  asset,

  /// 从网络下载的模型
  download,
}

/// TTS 模型配置
///
/// 定义了一个 TTS 模型的所有配置信息，包括模型文件路径、
/// 词典文件、说话人数量等。
@freezed
abstract class TtsModelConfig with _$TtsModelConfig {
  const factory TtsModelConfig({
    /// 模型唯一标识
    required String id,

    /// 显示名称
    required String name,

    /// 语言代码：zh/en/zh_en/multi
    required String language,

    /// 来源：asset/download
    required TtsModelSource source,

    /// 模型目录名
    required String modelDir,

    /// 模型文件名
    required String modelName,

    /// 词典文件（可选）
    String? lexicon,

    /// tokens 文件名（默认 tokens.txt）
    @Default('tokens.txt') String tokens,

    /// espeak-ng-data 目录（可选）
    String? dataDir,

    /// 词典目录（可选）
    String? dictDir,

    /// 规则 FST 文件，逗号分隔（可选）
    String? ruleFsts,

    /// 规则 FAR 文件，逗号分隔（可选）
    String? ruleFars,

    /// Kokoro voices.bin 文件（可选）
    String? voices,

    /// 说话人数量
    @Default(1) int numSpeakers,

    /// 模型大小（字节）
    @Default(0) int size,

    /// 下载地址（可选）
    String? downloadUrl,

    /// 是否已下载/可用
    @Default(false) bool isAvailable,

    /// 是否是当前激活的模型
    @Default(false) bool isActive,
  }) = _TtsModelConfig;

  factory TtsModelConfig.fromJson(Map<String, dynamic> json) =>
      _$TtsModelConfigFromJson(json);
}

/// 预定义的 TTS 模型列表
class TtsPredefinedModels {
  TtsPredefinedModels._();

  /// 所有预定义模型
  static const List<TtsModelConfig> models = [
    // 中英双语模型 - MeloTTS
    TtsModelConfig(
      id: 'vits-melo-tts-zh_en',
      name: 'MeloTTS 中英双语',
      language: 'zh_en',
      source: TtsModelSource.download,
      modelDir: 'vits-melo-tts-zh_en',
      modelName: 'model.onnx',
      lexicon: 'lexicon.txt',
      dictDir: 'dict',
      numSpeakers: 1,
      size: 50 * 1024 * 1024, // ~50MB
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-melo-tts-zh_en.tar.bz2',
    ),

    // 中文多说话人模型
    TtsModelConfig(
      id: 'vits-zh-hf-fanchen-C',
      name: '中文多说话人 (187人)',
      language: 'zh',
      source: TtsModelSource.download,
      modelDir: 'vits-zh-hf-fanchen-C',
      modelName: 'vits-zh-hf-fanchen-C.onnx',
      lexicon: 'lexicon.txt',
      numSpeakers: 187,
      size: 100 * 1024 * 1024, // ~100MB
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-zh-hf-fanchen-C.tar.bz2',
    ),

    // Kokoro 多语言模型
    TtsModelConfig(
      id: 'kokoro-multi-lang-v1_1',
      name: 'Kokoro 多语言 (103人)',
      language: 'multi',
      source: TtsModelSource.download,
      modelDir: 'kokoro-multi-lang-v1_1',
      modelName: 'model.onnx',
      voices: 'voices.bin',
      dataDir: 'espeak-ng-data',
      numSpeakers: 103,
      size: 200 * 1024 * 1024, // ~200MB
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/kokoro-multi-lang-v1_1.tar.bz2',
    ),

    // 英文模型 - Piper
    TtsModelConfig(
      id: 'vits-piper-en_US-amy-low',
      name: 'Piper English (Amy)',
      language: 'en',
      source: TtsModelSource.download,
      modelDir: 'vits-piper-en_US-amy-low',
      modelName: 'en_US-amy-low.onnx',
      dataDir: 'espeak-ng-data',
      numSpeakers: 1,
      size: 30 * 1024 * 1024, // ~30MB
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-piper-en_US-amy-low.tar.bz2',
    ),
  ];

  /// 根据ID获取模型配置
  static TtsModelConfig? getById(String id) {
    try {
      return models.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 获取指定语言的模型列表
  static List<TtsModelConfig> getByLanguage(String language) {
    return models.where((m) => m.language == language).toList();
  }

  /// 获取所有中英双语模型
  static List<TtsModelConfig> get chineseModels {
    return models
        .where((m) => m.language == 'zh' || m.language == 'zh_en')
        .toList();
  }
}
