import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'package:logger/logger.dart';

import '../models/tts_model_config.dart';
import 'tts_engine_service.dart';

/// Sherpa-ONNX TTS 引擎服务实现
///
/// 使用 sherpa_onnx Flutter 插件实现 TTS 功能。
class SherpaOnnxTtsEngineService implements TtsEngineService {
  sherpa.OfflineTts? _tts;
  final Logger _logger = Logger();
  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  int get numSpeakers => _tts?.numSpeakers ?? 1;

  @override
  Future<bool> initialize(TtsModelConfig config, String modelPath) async {
    try {
      // 释放旧的实例
      dispose();

      // 初始化 sherpa_onnx绑定
      sherpa.initBindings();

      // 构建模型文件路径
      final modelFile = p.join(modelPath, config.modelDir, config.modelName);
      final tokensFile = p.join(modelPath, config.modelDir, config.tokens);

      // 检查模型文件是否存在
      if (!File(modelFile).existsSync()) {
        _logger.e('Model file not found: $modelFile');
        return false;
      }

      // 构建 VITS 模型配置
      final vitsConfig = sherpa.OfflineTtsVitsModelConfig(
        model: modelFile,
        tokens: tokensFile,
        lexicon: config.lexicon != null
            ? p.join(modelPath, config.modelDir, config.lexicon!)
            : '',
        dataDir: config.dataDir != null
            ? p.join(modelPath, config.modelDir, config.dataDir!)
            : '',
        dictDir: config.dictDir != null
            ? p.join(modelPath, config.modelDir, config.dictDir!)
            : '',
        noiseScale: 0.667,
        noiseScaleW: 0.8,
        lengthScale: 1.0,
      );

      // 构建模型配置
      final modelConfig = sherpa.OfflineTtsModelConfig(
        vits: vitsConfig,
        kokoro: sherpa.OfflineTtsKokoroModelConfig(
          model: config.voices != null
              ? p.join(modelPath, config.modelDir, config.voices!)
              : '',
          voices: config.voices != null
              ? p.join(modelPath, config.modelDir, config.voices!)
              : '',
          tokens: tokensFile,
          dataDir: config.dataDir != null
              ? p.join(modelPath, config.modelDir, config.dataDir!)
              : '',
          lexicon: config.lexicon != null
              ? p.join(modelPath, config.modelDir, config.lexicon!)
              : '',
        ),
        numThreads: 2,
        debug: false,
        provider: 'cpu',
      );

      // 构建 TTS 配置
      final ttsConfig = sherpa.OfflineTtsConfig(
        model: modelConfig,
        ruleFsts: _buildRuleFsts(config, modelPath),
        ruleFars: _buildRuleFars(config, modelPath),
        maxNumSenetences: 1,
      );

      // 创建 TTS 实例
      _tts = sherpa.OfflineTts(ttsConfig);
      _isInitialized = _tts != null;

      if (_isInitialized) {
        _logger.i(
          'TTS engine initialized successfully. Num speakers: $numSpeakers',
        );
      }

      return _isInitialized;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize TTS engine',
        error: e,
        stackTrace: stackTrace,
      );
      _isInitialized = false;
      return false;
    }
  }

  /// 构建规则 FST 路径
  String _buildRuleFsts(TtsModelConfig config, String modelPath) {
    if (config.ruleFsts == null || config.ruleFsts!.isEmpty) {
      return '';
    }
    final parts = config.ruleFsts!.split(',');
    return parts.map((f) => p.join(modelPath, config.modelDir, f)).join(',');
  }

  /// 构建规则 FAR 路径
  String _buildRuleFars(TtsModelConfig config, String modelPath) {
    if (config.ruleFars == null || config.ruleFars!.isEmpty) {
      return '';
    }
    final parts = config.ruleFars!.split(',');
    return parts.map((f) => p.join(modelPath, config.modelDir, f)).join(',');
  }

  @override
  Future<TtsGenerationResult> synthesize(
    String text, {
    int speakerId = 0,
    double speed = 1.0,
  }) async {
    if (!_isInitialized || _tts == null) {
      return TtsGenerationResult(error: 'TTS engine not initialized');
    }

    if (text.trim().isEmpty) {
      return TtsGenerationResult(error: 'Text is empty');
    }

    try {
      final stopwatch = Stopwatch()..start();

      // 生成音频
      final audio = _tts!.generate(text: text, sid: speakerId, speed: speed);

      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds / 1000.0;

      if (audio.samples.isEmpty) {
        return TtsGenerationResult(
          error: 'Failed to generate audio',
          elapsed: elapsed,
        );
      }

      // 计算音频时长
      final duration = audio.samples.length / audio.sampleRate;

      return TtsGenerationResult(
        samples: audio.samples,
        sampleRate: audio.sampleRate,
        numSamples: audio.samples.length,
        duration: duration,
        elapsed: elapsed,
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to synthesize text', error: e, stackTrace: stackTrace);
      return TtsGenerationResult(error: 'Synthesis failed: $e');
    }
  }

  @override
  Future<String?> synthesizeToFile(
    String text,
    String outputPath, {
    int speakerId = 0,
    double speed = 1.0,
  }) async {
    final result = await synthesize(text, speakerId: speakerId, speed: speed);

    if (!result.isSuccess) {
      _logger.e('Failed to synthesize: ${result.error}');
      return null;
    }

    try {
      // 确保输出目录存在
      final outputFile = File(outputPath);
      if (!outputFile.parent.existsSync()) {
        outputFile.parent.createSync(recursive: true);
      }

      // 写入 WAV 文件
      final ok = sherpa.writeWave(
        filename: outputPath,
        samples: result.samples!,
        sampleRate: result.sampleRate,
      );

      if (ok) {
        _logger.i('Audio saved to: $outputPath');
        return outputPath;
      } else {
        _logger.e('Failed to write WAV file');
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to save audio file', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  void dispose() {
    _tts?.free();
    _tts = null;
    _isInitialized = false;
    _logger.i('TTS engine disposed');
  }
}
