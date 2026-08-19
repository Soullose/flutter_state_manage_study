import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/theme/predefined_themes.dart';
import '../../../common/theme/theme_config.dart';
import '../../../common/theme/theme_config_provider.dart';
import '../../../common/theme/switch_theme_mode.dart';
import '../widgets/theme_preview_card.dart';
import '../widgets/image_source_sheet.dart';

/// 主题设置页面
///
/// 提供预置主题选择和自定义图片主题功能
class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeConfig = ref.watch(themeConfigProvider);
    final themeMode = ref.watch(switchThemeModeProvider);
    final customColorScheme = ref.watch(customColorSchemeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('主题设置'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 明暗模式切换
          _buildThemeModeSection(context, ref, themeMode),
          const SizedBox(height: 24),

          // 预置主题选择
          _buildPredefinedThemesSection(context, ref, themeConfig),
          const SizedBox(height: 24),

          // 自定义图片主题
          _buildCustomThemeSection(
            context,
            ref,
            themeConfig,
            customColorScheme,
          ),
        ],
      ),
    );
  }

  /// 构建主题模式切换区域
  Widget _buildThemeModeSection(
    BuildContext context,
    WidgetRef ref,
    ThemeMode themeMode,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '显示模式',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('跟随系统'),
                  icon: Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('亮色'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('暗色'),
                  icon: Icon(Icons.dark_mode),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (modes) {
                ref.read(switchThemeModeProvider.notifier).setMode(modes.first);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建预置主题选择区域
  Widget _buildPredefinedThemesSection(
    BuildContext context,
    WidgetRef ref,
    ThemeConfig themeConfig,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '预置主题',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          itemCount: kPredefinedThemes.length,
          itemBuilder: (context, index) {
            final theme = kPredefinedThemes[index];
            final isSelected =
                themeConfig.type == ThemeType.predefined &&
                themeConfig.predefinedSchemeKey == theme.key;

            return ThemePreviewCard(
              theme: theme,
              isSelected: isSelected,
              onTap: () {
                ref
                    .read(themeConfigProvider.notifier)
                    .setPredefinedTheme(theme.key);
              },
            );
          },
        ),
      ],
    );
  }

  /// 构建自定义主题区域
  Widget _buildCustomThemeSection(
    BuildContext context,
    WidgetRef ref,
    ThemeConfig themeConfig,
    AsyncValue<dynamic> customColorScheme,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '自定义主题',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: colorScheme.surfaceContainerHighest,
          child: Column(
            children: [
              // 当前自定义主题状态
              if (themeConfig.type == ThemeType.custom &&
                  themeConfig.customImageSource != null)
                _buildCurrentCustomTheme(
                  context,
                  ref,
                  themeConfig,
                  customColorScheme,
                ),

              // 添加自定义主题按钮
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add_photo_alternate,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                title: const Text('从图片生成主题'),
                subtitle: const Text('选择一张图片自动生成配色方案'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showImageSourceDialog(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建当前自定义主题显示
  Widget _buildCurrentCustomTheme(
    BuildContext context,
    WidgetRef ref,
    ThemeConfig themeConfig,
    AsyncValue<dynamic> customColorScheme,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 图片缩略图
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: themeConfig.isNetworkImage
                ? Image.network(
                    themeConfig.customImageSource!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 60,
                      height: 60,
                      color: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.broken_image,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  )
                : Image.asset(
                    themeConfig.customImageSource!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 60,
                      height: 60,
                      color: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.broken_image,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          // 状态信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '当前使用自定义主题',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                customColorScheme.when(
                  data: (data) => Text(
                    '颜色方案已生成',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  loading: () => Row(
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '正在生成颜色方案...',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  error: (error, _) => Text(
                    '生成失败: $error',
                    style: TextStyle(fontSize: 12, color: colorScheme.error),
                  ),
                ),
              ],
            ),
          ),
          // 删除按钮
          IconButton(
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
            onPressed: () {
              ref.read(themeConfigProvider.notifier).resetToDefault();
            },
          ),
        ],
      ),
    );
  }

  /// 显示图片来源选择弹窗
  void _showImageSourceDialog(BuildContext context, WidgetRef ref) {
    ImageSourceSheet.show(
      context: context,
      onLocalImageSelected: (path) {
        ref
            .read(themeConfigProvider.notifier)
            .setCustomThemeFromLocalImage(path);
      },
      onNetworkImageSelected: (url) {
        ref
            .read(themeConfigProvider.notifier)
            .setCustomThemeFromNetworkImage(url);
      },
    );
  }
}
