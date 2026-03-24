import 'dart:typed_data';

import '../models/tts_model_config.dart';

/// TTS 生成结果
class TtsGenerationResult {
  final Float32List? samples;
  final int sampleRate;
  final int numSamples;
  final double duration;
  final double elapsed;
  final String? error;

  TtsGenerationResult({
    this.samples,
    this.sampleRate = 0,
    this.numSamples = 0,
    this.duration = 0,
    this.elapsed = 0,
    this.error,
  });

  bool get isSuccess => samples != null && error == null;
}

/// TTS 引擎服务接口
///
/// 定义了 TTS 引擎的核心功能，包括初始化、语音合成、资源释放等。
abstract class TtsEngineService {
  /// 初始化 TTS 引擎
  ///
  /// [config] 模型配置
  /// [modelPath] 模型所在的基础路径
  Future<bool> initialize(TtsModelConfig config, String modelPath);

  /// 检查引擎是否已初始化
  bool get isInitialized;

  /// 获取说话人数量
  int get numSpeakers;

  /// 合成语音
  ///
  /// [text] 要合成的文本
  /// [speakerId] 说话人 ID（默认 0）
  /// [speed] 语速（0.5 - 3.0，默认 1.0）
  Future<TtsGenerationResult> synthesize(
    String text, {
    int speakerId = 0,
    double speed = 1.0,
  });

  /// 合成语音并保存为 WAV 文件
  ///
  /// [text] 要合成的文本
  /// [outputPath] 输出文件路径
  /// [speakerId] 说话人 ID（默认 0）
  /// [speed] 语速（0.5 - 3.0，默认 1.0）
  /// 返回生成的文件路径，失败返回 null
  Future<String?> synthesizeToFile(
    String text,
    String outputPath, {
    int speakerId = 0,
    double speed = 1.0,
  });

  /// 释放资源
  void dispose();
}
