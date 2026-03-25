import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/theme/switch_theme_mode.dart';
import 'generated/l10n.dart';

/// 功能模块数据模型
class FeatureItem {
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final Color? color;

  const FeatureItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    this.color,
  });
}

/// 功能模块列表
const List<FeatureItem> _features = [
  FeatureItem(
    title: '计数器',
    description: 'Riverpod 状态管理示例，展示计数器的增减操作',
    icon: Icons.add_circle_outline,
    route: '/riverpodCounter',
    color: Colors.blue,
  ),
  FeatureItem(
    title: '设置',
    description: '应用设置页面，包含地址配置等选项',
    icon: Icons.settings_outlined,
    route: '/riverpodSetting',
    color: Colors.orange,
  ),
  FeatureItem(
    title: '计时器',
    description: '倒计时功能示例，展示 Stream 状态管理',
    icon: Icons.timer_outlined,
    route: '/riverpodTimer',
    color: Colors.green,
  ),
  FeatureItem(
    title: '主题设置',
    description: '颜色主题切换，支持预置主题和图片生成主题',
    icon: Icons.palette_outlined,
    route: '/themeSettings',
    color: Colors.purple,
  ),
  FeatureItem(
    title: 'TTS 语音合成',
    description: '离线语音合成功能，支持多种模型和发音人',
    icon: Icons.record_voice_over_outlined,
    route: '/tts',
    color: Colors.teal,
  ),
];

/// 首页
class AppPage extends ConsumerStatefulWidget {
  const AppPage({super.key});

  @override
  ConsumerState<AppPage> createState() => _AppPageState();
}

class _AppPageState extends ConsumerState<AppPage> {
  final List<bool> _cardVisible = List.generate(_features.length, (_) => false);

  @override
  void initState() {
    super.initState();
    _startStaggeredAnimation();
  }

  /// 启动交错动画
  void _startStaggeredAnimation() {
    for (int i = 0; i < _features.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          setState(() {
            _cardVisible[i] = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(switchThemeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).mainTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              ref.read(switchThemeModeProvider.notifier).toggle();
            },
            tooltip: themeMode == ThemeMode.dark ? '切换到亮色模式' : '切换到暗色模式',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.82,
          ),
          itemCount: _features.length,
          itemBuilder: (context, index) {
            return _AnimatedFeatureCard(
              feature: _features[index],
              visible: _cardVisible[index],
            );
          },
        ),
      ),
    );
  }
}

/// 带动画的功能卡片
class _AnimatedFeatureCard extends StatelessWidget {
  final FeatureItem feature;
  final bool visible;

  const _AnimatedFeatureCard({required this.feature, required this.visible});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.translationValues(0, visible ? 0 : 30, 0),
        child: _FeatureCard(feature: feature),
      ),
    );
  }
}

/// 功能卡片
class _FeatureCard extends StatelessWidget {
  final FeatureItem feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = feature.color ?? colorScheme.primary;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push(feature.route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hero 动画包裹的图标
              Hero(
                tag: 'hero_${feature.route}',
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(feature.icon, size: 40, color: cardColor),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                feature.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                feature.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
