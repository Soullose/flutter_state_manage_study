import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tts_model_config.dart';
import '../models/tts_state.dart';
import '../providers/tts_provider.dart';

/// TTS 模型管理页面
class TtsModelsPage extends ConsumerStatefulWidget {
  const TtsModelsPage({super.key});

  @override
  ConsumerState<TtsModelsPage> createState() => _TtsModelsPageState();
}

class _TtsModelsPageState extends ConsumerState<TtsModelsPage> {
  @override
  Widget build(BuildContext context) {
    final asyncTtsState = ref.watch(ttsProvider);
    final ttsNotifier = ref.read(ttsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('模型管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // 重新加载模型列表
              ref.invalidate(ttsProvider);
            },
          ),
        ],
      ),
      body: asyncTtsState.when(
        // 加载中状态
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在加载模型列表...'),
            ],
          ),
        ),
        // 错误状态
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('加载失败: $error'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
                onPressed: () {
                  ref.invalidate(ttsProvider);
                },
              ),
            ],
          ),
        ),
        // 成功状态
        data: (ttsState) => ttsState.isDownloading
            ? _buildDownloadProgress(ttsState)
            : _buildModelList(context, ttsState, ttsNotifier),
      ),
    );
  }

  /// 构建下载进度
  Widget _buildDownloadProgress(TtsState ttsState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            '下载中... ${(ttsState.downloadProgress * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            ttsState.statusMessage ?? '正在下载模型',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// 构建模型列表
  Widget _buildModelList(
    BuildContext context,
    TtsState ttsState,
    TtsNotifier ttsNotifier,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ttsState.models.length,
      itemBuilder: (context, index) {
        final model = ttsState.models[index];
        return _buildModelCard(context, model, ttsState, ttsNotifier);
      },
    );
  }

  /// 构建模型卡片
  Widget _buildModelCard(
    BuildContext context,
    TtsModelConfig model,
    TtsState ttsState,
    TtsNotifier ttsNotifier,
  ) {
    final isDownloading = ttsState.downloadingModelId == model.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 模型名称和语言
            Row(
              children: [
                Icon(_getLanguageIcon(model.language), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getLanguageLabel(model.language),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (model.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '当前使用',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // 模型信息
            Row(
              children: [
                Text(
                  '大小: ${_formatSize(model.size)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                if (model.numSpeakers > 1)
                  Text(
                    '说话人: ${model.numSpeakers}人',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!model.isAvailable)
                  ElevatedButton.icon(
                    icon: isDownloading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.download),
                    label: Text(isDownloading ? '下载中...' : '下载'),
                    onPressed: isDownloading
                        ? null
                        : () => _downloadModel(
                            this.context,
                            model.id,
                            ttsNotifier,
                          ),
                  ),
                if (model.isAvailable && !model.isActive)
                  TextButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('使用'),
                    onPressed: () =>
                        _setActiveModel(this.context, model.id, ttsNotifier),
                  ),
                if (model.isAvailable)
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('删除'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () =>
                        _confirmDelete(this.context, model.id, ttsNotifier),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 下载模型
  Future<void> _downloadModel(
    BuildContext context,
    String modelId,
    TtsNotifier ttsNotifier,
  ) async {
    final success = await ttsNotifier.downloadModel(modelId);
    if (mounted && context.mounted) {
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('模型下载成功')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('模型下载失败'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 设置激活模型
  Future<void> _setActiveModel(
    BuildContext context,
    String modelId,
    TtsNotifier ttsNotifier,
  ) async {
    final success = await ttsNotifier.setActiveModel(modelId);
    if (mounted && context.mounted && success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('模型已切换')));
    }
  }

  /// 确认删除
  Future<void> _confirmDelete(
    BuildContext context,
    String modelId,
    TtsNotifier ttsNotifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除此模型吗？删除后需要重新下载。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ttsNotifier.deleteModel(modelId);
    }
  }

  /// 获取语言图标
  IconData _getLanguageIcon(String language) {
    switch (language) {
      case 'zh':
        return Icons.translate;
      case 'en':
        return Icons.language;
      case 'zh_en':
        return Icons.g_translate;
      case 'multi':
        return Icons.public;
      default:
        return Icons.record_voice_over;
    }
  }

  /// 获取语言标签
  String _getLanguageLabel(String language) {
    switch (language) {
      case 'zh':
        return '中文';
      case 'en':
        return '英文';
      case 'zh_en':
        return '中英双语';
      case 'multi':
        return '多语言';
      default:
        return language;
    }
  }

  /// 格式化文件大小
  String _formatSize(int bytes) {
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
