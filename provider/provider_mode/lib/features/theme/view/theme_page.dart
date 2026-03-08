import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_mode/features/theme/models/app_theme.dart';
import 'package:provider_mode/features/theme/theme_provider.dart';

/// 主题设置页面
///
/// 展示如何使用Provider进行主题切换
class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题设置'),
        centerTitle: true,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 当前主题展示卡片
              _buildCurrentThemeCard(context, themeProvider),
              const SizedBox(height: 24),
              // 主题选择列表
              _buildThemeSelectionList(context, themeProvider),
              const SizedBox(height: 24),
              // 说明卡片
              _buildInfoCard(context),
            ],
          );
        },
      ),
    );
  }

  /// 构建当前主题展示卡片
  Widget _buildCurrentThemeCard(BuildContext context, ThemeProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              provider.currentTheme.icon,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '当前主题',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              provider.currentTheme.displayName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建主题选择列表
  Widget _buildThemeSelectionList(
      BuildContext context, ThemeProvider provider) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '选择主题',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Divider(height: 1),
          ...AppTheme.values.map((theme) => _buildThemeTile(
                context,
                theme,
                provider.currentTheme == theme,
                () => provider.setTheme(theme),
              )),
        ],
      ),
    );
  }

  /// 构建单个主题选项
  Widget _buildThemeTile(
    BuildContext context,
    AppTheme theme,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        theme.icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(theme.displayName),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : const Icon(Icons.radio_button_unchecked),
      onTap: onTap,
    );
  }

  /// 构建说明卡片
  Widget _buildInfoCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Provider使用说明',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '''• ThemeProvider 继承自 ChangeNotifier
• 使用 Consumer<ThemeProvider> 监听状态变化
• 调用 notifyListeners() 通知UI更新
• 主题设置会持久化存储到本地''',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
