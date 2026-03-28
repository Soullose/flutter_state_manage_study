import 'package:flutter/material.dart';

import '../models/tts_model_config.dart';

/// 模型选择器组件
class ModelSelector extends StatelessWidget {
  final List<TtsModelConfig> models;
  final TtsModelConfig? activeModel;
  final Function(String) onModelSelected;

  const ModelSelector({
    super.key,
    required this.models,
    this.activeModel,
    required this.onModelSelected,
  });

  @override
  Widget build(BuildContext context) {
    final availableModels = models.where((m) => m.isAvailable).toList();

    if (availableModels.isEmpty) {
      return const Text('没有可用的模型，请先下载模型', style: TextStyle(color: Colors.grey));
    }

    return DropdownButtonFormField<String>(
      initialValue: activeModel?.id,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: availableModels.map((model) {
        return DropdownMenuItem(
          value: model.id,
          child: Row(
            children: [
              Icon(_getLanguageIcon(model.language), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${model.name} · ${_getLanguageLabel(model.language)}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (model.numSpeakers > 1)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Chip(
                    label: Text('${model.numSpeakers}人'),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onModelSelected(value);
        }
      },
    );
  }

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
}
