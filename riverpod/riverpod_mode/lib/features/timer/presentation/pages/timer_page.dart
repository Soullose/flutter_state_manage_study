import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/timer_controller.dart';
import '../../state/timer_state.dart';

class TimerPage extends ConsumerWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerStateAsync = ref.watch(timerControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'hero_/riverpodTimer',
              flightShuttleBuilder: _flightShuttleBuilder,
              child: const Icon(Icons.timer_outlined),
            ),
            const SizedBox(width: 8),
            const Text('计时器'),
          ],
        ),
        centerTitle: true,
      ),
      body: Center(
        child: timerStateAsync.when(
          data: (state) => _buildTimerContent(context, ref, state),
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('Error: $err'),
        ),
      ),
    );
  }

  Widget _buildTimerContent(
    BuildContext context,
    WidgetRef ref,
    TimerState state,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = ref.read(timerControllerProvider.notifier);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 倒计时显示
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.primaryContainer,
            border: Border.all(color: colorScheme.primary, width: 4),
          ),
          child: Center(
            child: Text(
              _formatDuration(state.duration),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 48),
        // 状态文本
        Text(
          _getStateText(state),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 32),
        // 控制按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 重置按钮
            _ControlButton(
              icon: Icons.refresh,
              label: '重置',
              onPressed: () => controller.resetTimer(),
              color: colorScheme.error,
            ),
            const SizedBox(width: 24),
            // 开始/暂停/继续按钮
            switch (state) {
              TimeStateInitial() => _ControlButton(
                icon: Icons.play_arrow,
                label: '开始',
                onPressed: () => controller.startTimer(),
                color: Colors.green,
              ),
              TimerRunInProgress() => _ControlButton(
                icon: Icons.pause,
                label: '暂停',
                onPressed: () => controller.pauseTimer(),
                color: Colors.orange,
              ),
              TimerRunPause() => _ControlButton(
                icon: Icons.play_arrow,
                label: '继续',
                onPressed: () => controller.resumeTimer(),
                color: Colors.green,
              ),
              TimerRunComplete() => _ControlButton(
                icon: Icons.replay,
                label: '重新开始',
                onPressed: () => controller.startTimer(),
                color: Colors.blue,
              ),
            },
          ],
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getStateText(TimerState state) {
    return switch (state) {
      TimeStateInitial() => '准备开始',
      TimerRunInProgress() => '计时中...',
      TimerRunPause() => '已暂停',
      TimerRunComplete() => '计时完成！',
    };
  }

  static Widget _flightShuttleBuilder(
    BuildContext context,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return Icon(
      Icons.timer_outlined,
      size: 24,
      color: Theme.of(fromHeroContext).colorScheme.onSurface,
    );
  }
}

/// 控制按钮
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: label,
          onPressed: onPressed,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
