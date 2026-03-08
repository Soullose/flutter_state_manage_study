import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_mode/features/locale/models/app_locale.dart';
import 'package:provider_mode/features/locale/locale_provider.dart';

/// 语言设置页面
///
/// 展示如何使用Provider进行语言切换
class LocalePage extends StatelessWidget {
  const LocalePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('语言设置'),
        centerTitle: true,
      ),
      body: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 当前语言展示卡片
              _buildCurrentLocaleCard(context, localeProvider),
              const SizedBox(height: 24),
              // 语言选择列表
              _buildLocaleSelectionList(context, localeProvider),
              const SizedBox(height: 24),
              // 说明卡片
              _buildInfoCard(context),
            ],
          );
        },
      ),
    );
  }

  /// 构建当前语言展示卡片
  Widget _buildCurrentLocaleCard(
      BuildContext context, LocaleProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              provider.currentLocale.flag,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              '当前语言',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              provider.currentLocale.displayName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建语言选择列表
  Widget _buildLocaleSelectionList(
      BuildContext context, LocaleProvider provider) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '选择语言 / Select Language',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Divider(height: 1),
          ...AppLocale.values.map((locale) => _buildLocaleTile(
                context,
                locale,
                provider.currentLocale == locale,
                () => provider.setLocale(locale),
              )),
        ],
      ),
    );
  }

  /// 构建单个语言选项
  Widget _buildLocaleTile(
    BuildContext context,
    AppLocale locale,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Text(
        locale.flag,
        style: const TextStyle(fontSize: 28),
      ),
      title: Text(locale.displayName),
      subtitle: locale != AppLocale.system ? Text(locale.nativeName) : null,
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
                  '国际化使用说明',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '''• LocaleProvider 管理应用语言状态
• 返回null表示跟随系统语言设置
• 需要配合MaterialApp.locale使用
• 完整国际化需要arb文件和intl包''',
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
