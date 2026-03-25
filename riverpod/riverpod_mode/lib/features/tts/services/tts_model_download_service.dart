import 'dart:io';

import 'package:archive/archive.dart';
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
  ///
  /// 使用 archive 库实现两步解压：
  /// 1. BZip2Decoder 解压 bz2 压缩
  /// 2. TarDecoder 解压 tar 归档
  Future<void> _extractTarBz2(String tarBz2Path, String targetPath) async {
    try {
      _logger.i('Starting extraction of $tarBz2Path to $targetPath');

      // 1. 读取 bz2 压缩文件
      final bz2File = File(tarBz2Path);
      if (!bz2File.existsSync()) {
        throw FileSystemException('tar.bz2 file not found', tarBz2Path);
      }

      final bz2Bytes = await bz2File.readAsBytes();
      _logger.i('Read ${bz2Bytes.length} bytes from bz2 file');

      // 2. 解压 bz2 得到 tar 数据
      final tarBytes = BZip2Decoder().decodeBytes(bz2Bytes, verify: true);
      _logger.i('Decompressed bz2, tar size: ${tarBytes.length} bytes');

      // 3. 解压 tar 归档
      final archive = TarDecoder().decodeBytes(tarBytes);
      _logger.i('Extracted tar archive with ${archive.length} entries');

      // 4. 写入文件到目标目录
      int fileCount = 0;
      for (final entry in archive) {
        // 安全检查：防止目录穿越攻击
        final entryName = entry.name;
        if (entryName.contains('..') || entryName.startsWith('/')) {
          _logger.w('Skipping potentially unsafe path: $entryName');
          continue;
        }

        final filePath = p.join(targetPath, entryName);

        if (entry.isFile) {
          final file = File(filePath);
          // 确保父目录存在
          await file.parent.create(recursive: true);
          // 写入文件内容
          final content = entry.content as List<int>;
          await file.writeAsBytes(content);
          fileCount++;
          _logger.d('Extracted file: $filePath (${content.length} bytes)');
        } else {
          // 创建目录
          final dir = Directory(filePath);
          await dir.create(recursive: true);
          _logger.d('Created directory: $filePath');
        }
      }

      _logger.i(
        'Extraction completed: $fileCount files extracted to $targetPath',
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to extract archive', error: e, stackTrace: stackTrace);
      rethrow;
    }
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
