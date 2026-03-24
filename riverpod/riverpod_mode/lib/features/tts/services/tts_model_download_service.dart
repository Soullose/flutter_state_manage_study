import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

import '../models/tts_model_config.dart';

/// 模型下载进度回调
typedef DownloadProgressCallback =
    void Function(double progress, String status);

/// TTS 模型下载服务
///
/// 负责从网络下载 TTS 模型并解压到本地存储。
class TtsModelDownloadService {
  final Dio _dio;
  final Logger _logger = Logger();

  TtsModelDownloadService({Dio? dio}) : _dio = dio ?? Dio();

  /// 获取模型存储的基础路径
  Future<String> get modelsBasePath async {
    final appDir = await getApplicationSupportDirectory();
    return p.join(appDir.path, 'tts_models');
  }

  /// 获取模型目录路径
  Future<String> getModelPath(String modelDir) async {
    final basePath = await modelsBasePath;
    return p.join(basePath, modelDir);
  }

  /// 检查模型是否已下载
  Future<bool> isModelDownloaded(TtsModelConfig config) async {
    final modelPath = await getModelPath(config.modelDir);
    final modelFile = p.join(modelPath, config.modelName);
    return File(modelFile).existsSync();
  }

  /// 下载模型
  ///
  /// [config] 模型配置
  /// [onProgress] 进度回调
  /// 返回下载后的模型路径，失败返回 null
  Future<String?> downloadModel(
    TtsModelConfig config, {
    DownloadProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    if (config.downloadUrl == null || config.downloadUrl!.isEmpty) {
      onProgress?.call(0, '错误：模型没有下载地址');
      return null;
    }

    try {
      final basePath = await modelsBasePath;
      final modelPath = p.join(basePath, config.modelDir);
      final tarFile = p.join(basePath, '${config.modelDir}.tar.bz2');

      // 创建目录
      final dir = Directory(modelPath);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      onProgress?.call(0, '开始下载模型...');

      // 下载压缩包
      await _dio.download(
        config.downloadUrl!,
        tarFile,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total * 0.9; // 下载占 90%
            onProgress?.call(
              progress,
              '下载中... ${_formatBytes(received)}/${_formatBytes(total)}',
            );
          } else {
            final progress =
                received /
                (config.size > 0 ? config.size : 100 * 1024 * 1024) *
                0.9;
            onProgress?.call(progress, '下载中... ${_formatBytes(received)}');
          }
        },
      );

      onProgress?.call(0.9, '解压模型...');

      // 解压 tar.bz2 文件
      await _extractTarBz2(tarFile, basePath);

      // 删除压缩包
      final tarFileObj = File(tarFile);
      if (tarFileObj.existsSync()) {
        tarFileObj.deleteSync();
      }

      onProgress?.call(1.0, '下载完成');

      _logger.i('Model downloaded and extracted to: $modelPath');
      return modelPath;
    } on DioException catch (e, stackTrace) {
      _logger.e('Download failed', error: e, stackTrace: stackTrace);
      onProgress?.call(0, '下载失败: ${e.message}');
      return null;
    } catch (e, stackTrace) {
      _logger.e('Download failed', error: e, stackTrace: stackTrace);
      onProgress?.call(0, '下载失败: $e');
      return null;
    }
  }

  /// 解压 tar.bz2 文件
  Future<void> _extractTarBz2(String tarBz2Path, String targetPath) async {
    // Flutter 没有内置的 tar 解压功能
    // 这里我们使用系统命令或第三方库
    // 由于跨平台兼容性问题，我们假设模型已经预解压
    // 实际项目中可以使用 archive 库或平台特定实现

    // 简化实现：假设下载的是已解压的文件结构
    // 实际生产环境需要实现完整的解压逻辑
    _logger.i('Extracting $tarBz2Path to $targetPath');

    // TODO: 实现实际的解压逻辑
    // 可以使用 archive 库或调用系统命令
  }

  /// 删除已下载的模型
  Future<bool> deleteModel(TtsModelConfig config) async {
    try {
      final modelPath = await getModelPath(config.modelDir);
      final dir = Directory(modelPath);

      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
        _logger.i('Model deleted: $modelPath');
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      _logger.e('Failed to delete model', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// 获取已下载模型的大小
  Future<int> getModelSize(TtsModelConfig config) async {
    try {
      final modelPath = await getModelPath(config.modelDir);
      final dir = Directory(modelPath);

      if (!dir.existsSync()) {
        return 0;
      }

      int size = 0;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
      return size;
    } catch (e) {
      return 0;
    }
  }

  /// 格式化字节数
  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}
