import 'package:audioplayers/audioplayers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/tts_state.dart';
import '../providers/tts_provider.dart';
import '../widgets/model_selector.dart';
import '../widgets/speaker_selector.dart';
import '../widgets/speed_slider.dart';

/// TTS 主页面
class TtsPage extends ConsumerStatefulWidget {
  const TtsPage({super.key});

  @override
  ConsumerState<TtsPage> createState() => _TtsPageState();
}

class _TtsPageState extends ConsumerState<TtsPage> {
  late final TextEditingController _textController;
  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncTtsState = ref.watch(ttsProvider);
    final ttsNotifier = ref.read(ttsProvider.notifier);

    // 监听错误信息
    ref.listen<AsyncValue<TtsState>>(ttsProvider, (previous, next) {
      final prevErrorMsg = previous?.value?.errorMessage;
      final nextErrorMsg = next.value?.errorMessage;

      // 只有当错误信息从无到有或发生变化时才显示 SnackBar
      if (nextErrorMsg != null &&
          nextErrorMsg.isNotEmpty &&
          prevErrorMsg != nextErrorMsg) {
        // 延迟到当前帧完成后执行，避免在 build 期间修改状态导致 ParentData dirty 错误
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(nextErrorMsg),
                backgroundColor: Colors.red,
              ),
            );
            ttsNotifier.clearError();
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('文本转语音'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/tts/models');
            },
          ),
        ],
      ),
      body: asyncTtsState.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在初始化 TTS...'),
            ],
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('初始化失败: $error'),
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
        data: (ttsState) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 模型选择卡片
              _buildModelCard(context, ttsState, ttsNotifier),

              const SizedBox(height: 16),

              // 参数调节卡片
              _buildParamsCard(context, ttsState, ttsNotifier),

              const SizedBox(height: 16),

              // 文本输入卡片
              _buildInputCard(context, ttsState, ttsNotifier),

              const SizedBox(height: 16),

              // 控制按钮
              _buildControlButtons(context, ttsState, ttsNotifier),

              const SizedBox(height: 16),

              // 状态信息
              _buildStatusCard(context, ttsState),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建模型选择卡片
  Widget _buildModelCard(
    BuildContext context,
    TtsState ttsState,
    TtsNotifier ttsNotifier,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('当前模型', style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('管理模型'),
                  onPressed: () {
                    context.push('/tts/models');
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (ttsState.activeModel != null)
              ModelSelector(
                models: ttsState.models,
                activeModel: ttsState.activeModel,
                onModelSelected: (modelId) {
                  ttsNotifier.setActiveModel(modelId);
                },
              )
            else
              const Text('请先下载并选择一个模型', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  /// 构建参数调节卡片
  Widget _buildParamsCard(
    BuildContext context,
    TtsState ttsState,
    TtsNotifier ttsNotifier,
  ) {
    final engine = ref.read(ttsEngineProvider);
    final numSpeakers = engine.numSpeakers;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('参数调节', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),

            // 语速滑块
            SpeedSlider(
              speed: ttsState.speed,
              onSpeedChanged: (speed) {
                ttsNotifier.setSpeed(speed);
              },
            ),

            const SizedBox(height: 16),

            // 说话人选择
            if (numSpeakers > 1)
              SpeakerSelector(
                speakerId: ttsState.speakerId,
                numSpeakers: numSpeakers,
                onSpeakerChanged: (speakerId) {
                  ttsNotifier.setSpeakerId(speakerId);
                },
              ),
          ],
        ),
      ),
    );
  }

  /// 构建文本输入卡片
  Widget _buildInputCard(
    BuildContext context,
    TtsState ttsState,
    TtsNotifier ttsNotifier,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('输入文本', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '请输入要转换的文本...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建控制按钮
  Widget _buildControlButtons(
    BuildContext context,
    TtsState ttsState,
    TtsNotifier ttsNotifier,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 生成按钮
        ElevatedButton.icon(
          icon: ttsState.isGenerating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.play_arrow),
          label: Text(ttsState.isGenerating ? '生成中...' : '生成语音'),
          onPressed: ttsState.isGenerating || ttsState.activeModel == null
              ? null
              : () async {
                  final text = _textController.text.trim();
                  if (text.isEmpty) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('请输入文本')));
                    return;
                  }

                  await ttsNotifier.synthesize(text);
                },
        ),

        // 播放按钮
        ElevatedButton.icon(
          icon: Icon(_isPlaying ? Icons.stop : Icons.replay),
          label: Text(_isPlaying ? '停止' : '重播'),
          onPressed: ttsState.lastGeneratedPath == null
              ? null
              : () async {
                  if (_isPlaying) {
                    await _audioPlayer.stop();
                    setState(() {
                      _isPlaying = false;
                    });
                  } else {
                    await _audioPlayer.play(
                      DeviceFileSource(ttsState.lastGeneratedPath!),
                    );
                    setState(() {
                      _isPlaying = true;
                    });
                  }
                },
        ),

        // 清空按钮
        OutlinedButton.icon(
          icon: const Icon(Icons.clear),
          label: const Text('清空'),
          onPressed: () {
            _textController.clear();
          },
        ),
      ],
    );
  }

  /// 构建状态信息卡片
  Widget _buildStatusCard(BuildContext context, TtsState ttsState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('状态信息', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (ttsState.statusMessage != null)
              Text(
                ttsState.statusMessage!,
                style: const TextStyle(color: Colors.blue),
              ),
            if (ttsState.lastGeneratedPath != null) ...[
              const SizedBox(height: 8),
              Text(
                '音频时长: ${ttsState.lastGeneratedDuration.toStringAsFixed(1)}s',
              ),
              Text(
                '生成耗时: ${ttsState.lastGeneratedElapsed.toStringAsFixed(2)}s',
              ),
              Text(
                'RTF: ${(ttsState.lastGeneratedElapsed / ttsState.lastGeneratedDuration).toStringAsFixed(3)}',
              ),
            ],
            if (ttsState.statusMessage == null &&
                ttsState.lastGeneratedPath == null)
              const Text('等待操作...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
