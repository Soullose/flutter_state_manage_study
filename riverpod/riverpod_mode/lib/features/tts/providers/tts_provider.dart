import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import '../models/tts_model_config.dart';
import '../models/tts_state.dart';
import '../services/sherpa_onnx_tts_engine_service.dart';
import '../services/tts_engine_service.dart';
import '../services/tts_model_download_service.dart';

part 'tts_provider.g.dart';

/// TTS 引擎服务 Provider
@riverpod
TtsEngineService ttsEngine(Ref ref) {
  final service = SherpaOnnxTtsEngineService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
}

/// 模型下载服务 Provider
@riverpod
TtsModelDownloadService modelDownloadService(Ref ref) {
  return TtsModelDownloadService();
}

/// SharedPreferences Provider
@riverpod
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return await SharedPreferences.getInstance();
}

/// 已下载模型 ID 列表 Provider
@riverpod
Future<List<String>> downloadedModelIds(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return prefs.getStringList('tts_downloaded_models') ?? [];
}

/// 当前激活模型 ID Provider
@riverpod
Future<String?> activeModelId(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return prefs.getString('tts_active_model');
}

/// TTS 状态 Notifier
@riverpod
class TtsNotifier extends _$TtsNotifier {
  final Logger _logger = Logger();

  @override
  TtsState build() {
    return const TtsState();
  }

  /// 初始化 TTS
  Future<void> initialize() async {
    if (state.isInitialized) {
      return;
    }

    state = state.copyWith(statusMessage: '正在初始化...');

    try {
      // 加载模型列表
      await loadModels();

      // 获取当前激活的模型
      final prefs = await SharedPreferences.getInstance();
      final activeId = prefs.getString('tts_active_model');

      if (activeId != null && state.models.isNotEmpty) {
        TtsModelConfig? activeModel;
        try {
          activeModel = state.models.firstWhere(
            (m) => m.id == activeId,
            orElse: () => state.models.first,
          );
        } catch (_) {
          activeModel = null;
        }

        if (activeModel != null && activeModel.isAvailable) {
          await _initializeEngine(activeModel);
        }
      }

      state = state.copyWith(isInitialized: true, statusMessage: '初始化完成');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize TTS', error: e, stackTrace: stackTrace);
      state = state.copyWith(errorMessage: '初始化失败: $e', statusMessage: null);
    }
  }

  /// 加载模型列表
  Future<void> loadModels() async {
    final downloadedIds = await ref.read(downloadedModelIdsProvider.future);

    final models = TtsPredefinedModels.models.map((config) {
      final isDownloaded = downloadedIds.contains(config.id);
      return config.copyWith(isAvailable: isDownloaded, isActive: false);
    }).toList();

    state = state.copyWith(models: models);
  }

  /// 下载模型
  Future<bool> downloadModel(String modelId) async {
    final modelIndex = state.models.indexWhere((m) => m.id == modelId);
    if (modelIndex == -1) {
      state = state.copyWith(errorMessage: '模型未找到: $modelId');
      return false;
    }

    final model = state.models[modelIndex];

    if (model.isAvailable) {
      state = state.copyWith(statusMessage: '模型已下载');
      return true;
    }

    state = state.copyWith(
      isDownloading: true,
      downloadingModelId: modelId,
      downloadProgress: 0,
      statusMessage: '开始下载模型...',
    );

    final downloadService = ref.read(modelDownloadServiceProvider);

    final result = await downloadService.downloadModel(
      model,
      onProgress: (progress, status) {
        state = state.copyWith(
          downloadProgress: progress,
          statusMessage: status,
        );
      },
    );

    if (result != null) {
      // 保存到已下载列表
      final prefs = await SharedPreferences.getInstance();
      final downloadedIds = prefs.getStringList('tts_downloaded_models') ?? [];
      if (!downloadedIds.contains(modelId)) {
        downloadedIds.add(modelId);
        await prefs.setStringList('tts_downloaded_models', downloadedIds);
      }

      // 刷新 downloadedModelIdsProvider
      ref.invalidate(downloadedModelIdsProvider);

      // 更新状态
      final updatedModels = List<TtsModelConfig>.from(state.models);
      updatedModels[modelIndex] = model.copyWith(isAvailable: true);

      state = state.copyWith(
        models: updatedModels,
        isDownloading: false,
        downloadingModelId: null,
        downloadProgress: 1,
        statusMessage: '模型下载完成',
      );

      return true;
    } else {
      state = state.copyWith(
        isDownloading: false,
        downloadingModelId: null,
        downloadProgress: 0,
        errorMessage: '模型下载失败',
      );
      return false;
    }
  }

  /// 设置激活模型
  Future<bool> setActiveModel(String modelId) async {
    final modelIndex = state.models.indexWhere((m) => m.id == modelId);
    if (modelIndex == -1) {
      state = state.copyWith(errorMessage: '模型未找到: $modelId');
      return false;
    }

    final model = state.models[modelIndex];

    if (!model.isAvailable) {
      state = state.copyWith(errorMessage: '模型未下载');
      return false;
    }

    state = state.copyWith(statusMessage: '正在加载模型...');

    final success = await _initializeEngine(model);

    if (success) {
      // 保存激活模型 ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tts_active_model', modelId);

      // 更新状态
      final updatedModels = state.models.map((m) {
        return m.copyWith(isActive: m.id == modelId);
      }).toList();

      state = state.copyWith(
        models: updatedModels,
        activeModel: model.copyWith(isActive: true),
        speakerId: 0,
        statusMessage: '模型已加载',
      );

      return true;
    } else {
      state = state.copyWith(errorMessage: '模型加载失败', statusMessage: null);
      return false;
    }
  }

  /// 初始化 TTS 引擎
  Future<bool> _initializeEngine(TtsModelConfig config) async {
    final engine = ref.read(ttsEngineProvider);
    final downloadService = ref.read(modelDownloadServiceProvider);
    final modelPath = await downloadService.modelsBasePath;

    return await engine.initialize(config, modelPath);
  }

  /// 设置语速
  void setSpeed(double speed) {
    state = state.copyWith(speed: speed.clamp(0.5, 3.0));
  }

  /// 设置说话人
  void setSpeakerId(int speakerId) {
    final engine = ref.read(ttsEngineProvider);
    final maxSpeakerId = engine.numSpeakers - 1;

    state = state.copyWith(
      speakerId: speakerId.clamp(0, maxSpeakerId > 0 ? maxSpeakerId : 0),
    );
  }

  /// 合成语音
  Future<String?> synthesize(String text) async {
    if (text.trim().isEmpty) {
      state = state.copyWith(errorMessage: '请输入文本');
      return null;
    }

    final engine = ref.read(ttsEngineProvider);

    if (!engine.isInitialized) {
      state = state.copyWith(errorMessage: 'TTS 引擎未初始化');
      return null;
    }

    state = state.copyWith(
      isGenerating: true,
      errorMessage: null,
      statusMessage: '正在生成语音...',
    );

    try {
      // 生成输出文件路径
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final suffix =
          '-sid-${state.speakerId}-speed-${state.speed.toStringAsFixed(1)}';
      final outputPath = p.join(
        appDir.path,
        'tts_output',
        'tts_$timestamp$suffix.wav',
      );

      // 合成并保存到文件
      final result = await engine.synthesizeToFile(
        text,
        outputPath,
        speakerId: state.speakerId,
        speed: state.speed,
      );

      if (result != null) {
        // 获取生成结果信息
        final synthResult = await engine.synthesize(
          text,
          speakerId: state.speakerId,
          speed: state.speed,
        );

        state = state.copyWith(
          isGenerating: false,
          lastGeneratedPath: result,
          lastGeneratedDuration: synthResult.duration,
          lastGeneratedElapsed: synthResult.elapsed,
          statusMessage:
              '生成完成: ${synthResult.duration.toStringAsFixed(1)}s 音频, 耗时 ${synthResult.elapsed.toStringAsFixed(2)}s',
        );

        return result;
      } else {
        state = state.copyWith(isGenerating: false, errorMessage: '语音生成失败');
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to synthesize', error: e, stackTrace: stackTrace);
      state = state.copyWith(isGenerating: false, errorMessage: '生成失败: $e');
      return null;
    }
  }

  /// 删除模型
  Future<bool> deleteModel(String modelId) async {
    final modelIndex = state.models.indexWhere((m) => m.id == modelId);
    if (modelIndex == -1) {
      state = state.copyWith(errorMessage: '模型未找到: $modelId');
      return false;
    }

    final model = state.models[modelIndex];

    if (model.isActive) {
      // 如果是当前激活的模型，先释放引擎
      final engine = ref.read(ttsEngineProvider);
      engine.dispose();
      state = state.copyWith(activeModel: null, speakerId: 0);
    }

    final downloadService = ref.read(modelDownloadServiceProvider);
    final success = await downloadService.deleteModel(model);

    if (success) {
      // 从已下载列表中移除
      final prefs = await SharedPreferences.getInstance();
      final downloadedIds = prefs.getStringList('tts_downloaded_models') ?? [];
      downloadedIds.remove(modelId);
      await prefs.setStringList('tts_downloaded_models', downloadedIds);

      // 刷新 downloadedModelIdsProvider
      ref.invalidate(downloadedModelIdsProvider);

      // 更新状态
      final updatedModels = List<TtsModelConfig>.from(state.models);
      updatedModels[modelIndex] = model.copyWith(
        isAvailable: false,
        isActive: false,
      );

      state = state.copyWith(models: updatedModels, statusMessage: '模型已删除');

      return true;
    } else {
      state = state.copyWith(errorMessage: '删除模型失败');
      return false;
    }
  }

  /// 清除错误信息
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// 清除状态信息
  void clearStatus() {
    state = state.copyWith(statusMessage: null);
  }

  /// 获取当前模型的说话人数量
  int get numSpeakers {
    final engine = ref.read(ttsEngineProvider);
    return engine.numSpeakers;
  }
}
