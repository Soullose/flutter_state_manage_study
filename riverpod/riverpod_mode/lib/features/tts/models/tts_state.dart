import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'tts_model_config.dart';

part 'tts_state.freezed.dart';

/// TTS 状态
///
/// 管理 TTS 功能的所有状态信息，包括模型列表、当前激活模型、
/// 语速、说话人等。
@freezed
abstract class TtsState with _$TtsState {
  const factory TtsState({
    /// 可用模型列表
    @Default([]) List<TtsModelConfig> models,

    /// 当前激活的模型
    @Default(null) TtsModelConfig? activeModel,

    /// TTS 引擎是否已初始化
    @Default(false) bool isInitialized,

    /// 是否正在生成语音
    @Default(false) bool isGenerating,

    /// 是否正在下载模型
    @Default(false) bool isDownloading,

    /// 下载进度 (0.0 - 1.0)
    @Default(0.0) double downloadProgress,

    /// 当前下载的模型ID
    @Default(null) String? downloadingModelId,

    /// 语速 (0.5 - 3.0)
    @Default(1.0) double speed,

    /// 当前说话人 ID
    @Default(0) int speakerId,

    /// 最后生成的音频文件路径
    @Default(null) String? lastGeneratedPath,

    /// 最后生成的音频时长（秒）
    @Default(0.0) double lastGeneratedDuration,

    /// 最后生成的耗时（秒）
    @Default(0.0) double lastGeneratedElapsed,

    /// 错误信息
    @Default(null) String? errorMessage,

    /// 状态信息
    @Default(null) String? statusMessage,
  }) = _TtsState;
}

/// TTS 生成结果
class TtsGenerationResult {
  final Uint8List? samples;
  final int sampleRate;
  final double duration;
  final double elapsed;
  final String? error;

  TtsGenerationResult({
    this.samples,
    this.sampleRate = 0,
    this.duration = 0,
    this.elapsed = 0,
    this.error,
  });

  bool get isSuccess => samples != null && error == null;
}
