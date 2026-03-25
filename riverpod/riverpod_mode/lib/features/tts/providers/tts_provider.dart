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
///
/// 使用 keepAlive: true 确保引擎在整个应用生命周期内保持活跃，
/// 避免因 autoDispose 导致引擎被意外销毁。
@Riverpod(keepAlive: true)
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

/// TTS 状态 AsyncNotifier
///
/// 使用 AsyncNotifier 在初始化时自动加载模型列表，
/// 解决页面打开时空白的问题。
@riverpod
class TtsNotifier extends _$TtsNotifier {
  final Logger _logger = Logger();

  @override
  Future<TtsState> build() async {
    // 在初始化时自动加载模型列表
    return await _loadInitialState();
  }

  /// 加载初始状态
  Future<TtsState> _loadInitialState() async {
    final downloadedIds = await ref.watch(downloadedModelIdsProvider.future);

    final models = TtsPredefinedModels.models.map((config) {
      final isDownloaded = downloadedIds.contains(config.id);
      return config.copyWith(isAvailable: isDownloaded, isActive: false);
    }).toList();

    // 获取当前激活的模型
    final prefs = await SharedPreferences.getInstance();
    final activeId = prefs.getString('tts_active_model');

    TtsModelConfig? activeModel;
    if (activeId != null && models.isNotEmpty) {
      try {
        activeModel = models.firstWhere(
          (m) => m.id == activeId && m.isAvailable,
          orElse: () => models.firstWhere(
            (m) => m.isAvailable,
            orElse: () => models.first,
          ),
        );
      } catch (_) {
        activeModel = null;
      }

      // 如果找到可用模型，初始化引擎
      if (activeModel != null && activeModel.isAvailable) {
        await _initializeEngine(activeModel);
        final index = models.indexWhere((m) => m.id == activeModel!.id);
        if (index != -1) {
          models[index] = activeModel.copyWith(isActive: true);
        }
      }
    }

    return TtsState(
      models: models,
      activeModel: activeModel?.isAvailable == true ? activeModel : null,
      isInitialized: true,
    );
  }

  /// 初始化 TTS（兼容旧代码，现在自动在 build 中完成）
  Future<void> initialize() async {
    // 如果已经初始化，直接返回
    final currentState = state.value;
    if (currentState?.isInitialized == true) {
      return;
    }

    // 触发重新加载
    ref.invalidateSelf();
    await future;
  }

  /// 重新加载模型列表
  Future<void> loadModels() async {
    final currentState = state.value ?? const TtsState();

    final downloadedIds = await ref.read(downloadedModelIdsProvider.future);

    final models = TtsPredefinedModels.models.map((config) {
      final isDownloaded = downloadedIds.contains(config.id);
      return config.copyWith(isAvailable: isDownloaded, isActive: false);
    }).toList();

    state = AsyncValue.data(currentState.copyWith(models: models));
  }

  /// 下载模型
  Future<bool> downloadModel(String modelId) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final modelIndex = currentState.models.indexWhere((m) => m.id == modelId);
    if (modelIndex == -1) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: '模型未找到: $modelId'),
      );
      return false;
    }

    final model = currentState.models[modelIndex];

    if (model.isAvailable) {
      state = AsyncValue.data(currentState.copyWith(statusMessage: '模型已下载'));
      return true;
    }

    state = AsyncValue.data(
      currentState.copyWith(
        isDownloading: true,
        downloadingModelId: modelId,
        downloadProgress: 0,
        statusMessage: '开始下载模型...',
      ),
    );

    final downloadService = ref.read(modelDownloadServiceProvider);

    final result = await downloadService.downloadModel(
      model,
      onProgress: (progress, status) {
        final current = state.value;
        if (current != null) {
          state = AsyncValue.data(
            current.copyWith(downloadProgress: progress, statusMessage: status),
          );
        }
      },
    );

    final latestState = state.value;
    if (latestState == null) return false;

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
      final updatedModels = List<TtsModelConfig>.from(latestState.models);
      updatedModels[modelIndex] = model.copyWith(isAvailable: true);

      state = AsyncValue.data(
        latestState.copyWith(
          models: updatedModels,
          isDownloading: false,
          downloadingModelId: null,
          downloadProgress: 1,
          statusMessage: '模型下载完成',
        ),
      );

      return true;
    } else {
      state = AsyncValue.data(
        latestState.copyWith(
          isDownloading: false,
          downloadingModelId: null,
          downloadProgress: 0,
          errorMessage: '模型下载失败',
        ),
      );
      return false;
    }
  }

  /// 设置激活模型
  Future<bool> setActiveModel(String modelId) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final modelIndex = currentState.models.indexWhere((m) => m.id == modelId);
    if (modelIndex == -1) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: '模型未找到: $modelId'),
      );
      return false;
    }

    final model = currentState.models[modelIndex];

    if (!model.isAvailable) {
      state = AsyncValue.data(currentState.copyWith(errorMessage: '模型未下载'));
      return false;
    }

    state = AsyncValue.data(currentState.copyWith(statusMessage: '正在加载模型...'));

    final success = await _initializeEngine(model);

    final latestState = state.value;
    if (latestState == null) return false;

    if (success) {
      // 保存激活模型 ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tts_active_model', modelId);

      // 更新状态
      final updatedModels = latestState.models.map((m) {
        return m.copyWith(isActive: m.id == modelId);
      }).toList();

      state = AsyncValue.data(
        latestState.copyWith(
          models: updatedModels,
          activeModel: model.copyWith(isActive: true),
          speakerId: 0,
          statusMessage: '模型已加载',
        ),
      );

      return true;
    } else {
      state = AsyncValue.data(
        latestState.copyWith(errorMessage: '模型加载失败', statusMessage: null),
      );
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
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(speed: speed.clamp(0.5, 3.0)),
    );
  }

  /// 设置说话人
  void setSpeakerId(int speakerId) {
    final currentState = state.value;
    if (currentState == null) return;

    final engine = ref.read(ttsEngineProvider);
    final maxSpeakerId = engine.numSpeakers - 1;

    state = AsyncValue.data(
      currentState.copyWith(
        speakerId: speakerId.clamp(0, maxSpeakerId > 0 ? maxSpeakerId : 0),
      ),
    );
  }

  /// 合成语音
  Future<String?> synthesize(String text) async {
    final currentState = state.value;
    if (currentState == null) return null;

    if (text.trim().isEmpty) {
      state = AsyncValue.data(currentState.copyWith(errorMessage: '请输入文本'));
      return null;
    }

    final engine = ref.read(ttsEngineProvider);

    if (!engine.isInitialized) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: 'TTS 引擎未初始化'),
      );
      return null;
    }

    state = AsyncValue.data(
      currentState.copyWith(
        isGenerating: true,
        errorMessage: null,
        statusMessage: '正在生成语音...',
      ),
    );

    try {
      // 生成输出文件路径
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final latestState = state.value ?? currentState;
      final suffix =
          '-sid-${latestState.speakerId}-speed-${latestState.speed.toStringAsFixed(1)}';
      final outputPath = p.join(
        appDir.path,
        'tts_output',
        'tts_$timestamp$suffix.wav',
      );

      // 合成并保存到文件
      final result = await engine.synthesizeToFile(
        text,
        outputPath,
        speakerId: latestState.speakerId,
        speed: latestState.speed,
      );

      if (result != null) {
        // 获取生成结果信息
        final synthResult = await engine.synthesize(
          text,
          speakerId: latestState.speakerId,
          speed: latestState.speed,
        );

        state = AsyncValue.data(
          latestState.copyWith(
            isGenerating: false,
            lastGeneratedPath: result,
            lastGeneratedDuration: synthResult.duration,
            lastGeneratedElapsed: synthResult.elapsed,
            statusMessage:
                '生成完成: ${synthResult.duration.toStringAsFixed(1)}s 音频, 耗时 ${synthResult.elapsed.toStringAsFixed(2)}s',
          ),
        );

        return result;
      } else {
        state = AsyncValue.data(
          latestState.copyWith(isGenerating: false, errorMessage: '语音生成失败'),
        );
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to synthesize', error: e, stackTrace: stackTrace);
      final latestState = state.value ?? currentState;
      state = AsyncValue.data(
        latestState.copyWith(isGenerating: false, errorMessage: '生成失败: $e'),
      );
      return null;
    }
  }

  /// 删除模型
  Future<bool> deleteModel(String modelId) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final modelIndex = currentState.models.indexWhere((m) => m.id == modelId);
    if (modelIndex == -1) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: '模型未找到: $modelId'),
      );
      return false;
    }

    final model = currentState.models[modelIndex];

    if (model.isActive) {
      // 如果是当前激活的模型，先释放引擎
      final engine = ref.read(ttsEngineProvider);
      engine.dispose();
      state = AsyncValue.data(
        currentState.copyWith(activeModel: null, speakerId: 0),
      );
    }

    final downloadService = ref.read(modelDownloadServiceProvider);
    final success = await downloadService.deleteModel(model);

    final latestState = state.value;
    if (latestState == null) return false;

    if (success) {
      // 从已下载列表中移除
      final prefs = await SharedPreferences.getInstance();
      final downloadedIds = prefs.getStringList('tts_downloaded_models') ?? [];
      downloadedIds.remove(modelId);
      await prefs.setStringList('tts_downloaded_models', downloadedIds);

      // 刷新 downloadedModelIdsProvider
      ref.invalidate(downloadedModelIdsProvider);

      // 更新状态
      final updatedModels = List<TtsModelConfig>.from(latestState.models);
      updatedModels[modelIndex] = model.copyWith(
        isAvailable: false,
        isActive: false,
      );

      state = AsyncValue.data(
        latestState.copyWith(models: updatedModels, statusMessage: '模型已删除'),
      );

      return true;
    } else {
      state = AsyncValue.data(latestState.copyWith(errorMessage: '删除模型失败'));
      return false;
    }
  }

  /// 清除错误信息
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    // 只有当 errorMessage 不为 null 时才更新状态，避免无限循环
    if (currentState.errorMessage != null) {
      state = AsyncValue.data(currentState.copyWith(errorMessage: null));
    }
  }

  /// 清除状态信息
  void clearStatus() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(statusMessage: null));
  }

  /// 获取当前模型的说话人数量
  int get numSpeakers {
    final engine = ref.read(ttsEngineProvider);
    return engine.numSpeakers;
  }
}
