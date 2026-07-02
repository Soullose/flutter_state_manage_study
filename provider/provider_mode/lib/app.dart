import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider_mode/features/locale/locale_provider.dart';
import 'package:provider_mode/features/theme/theme_provider.dart';
import 'package:provider_mode/l10n/app_localizations.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        centerTitle: true,
        actions: [
          // 快速切换主题按钮
          IconButton(
            icon: Consumer<ThemeProvider>(
              builder: (context, theme, _) => Icon(
                theme.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
            tooltip: l10n.toggleTheme,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 欢迎卡片
          _buildWelcomeCard(context, l10n),
          const SizedBox(height: 24),

          // 功能示例分组
          _buildSectionHeader(context, l10n.providerExamples),
          const SizedBox(height: 12),
          _buildExampleGrid(context, l10n),

          const SizedBox(height: 24),

          // 状态概览
          _buildSectionHeader(context, l10n.currentStatus),
          const SizedBox(height: 12),
          _buildStatusCard(context, l10n),
        ],
      ),
    );
  }

  /// 构建欢迎卡片
  Widget _buildWelcomeCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.school,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.welcomeMessage,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.welcomeSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建分组标题
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  /// 构建示例网格
  Widget _buildExampleGrid(BuildContext context, AppLocalizations l10n) {
    final examples = [
      _ExampleItem(
        icon: Icons.calculate,
        title: l10n.counter,
        subtitle: l10n.counterSubtitle,
        route: '/providerCounter',
        color: Colors.blue,
      ),
      _ExampleItem(
        icon: Icons.palette,
        title: l10n.themeSwitch,
        subtitle: l10n.themeSwitchSubtitle,
        route: '/theme',
        color: Colors.purple,
      ),
      _ExampleItem(
        icon: Icons.language,
        title: l10n.multiLanguage,
        subtitle: l10n.multiLanguageSubtitle,
        route: '/locale',
        color: Colors.orange,
      ),
      _ExampleItem(
        icon: Icons.settings,
        title: l10n.appSettings,
        subtitle: l10n.appSettingsSubtitle,
        route: '/settings',
        color: Colors.teal,
      ),
      _ExampleItem(
        icon: Icons.bug_report,
        title: l10n.errorLog,
        subtitle: l10n.errorLogSubtitle,
        route: '/logs',
        color: Colors.red,
      ),
      _ExampleItem(
        icon: Icons.login,
        title: 'Provider认证',
        subtitle: 'Mock登录/登出示例',
        route: '/auth',
        color: Colors.indigo,
      ),
      _ExampleItem(
        icon: Icons.cloud,
        title: 'MQTT状态',
        subtitle: '连接状态监听示例',
        route: '/mqtt',
        color: Colors.cyan,
      ),
      _ExampleItem(
        icon: Icons.smart_toy,
        title: '流式聊天',
        subtitle: '仿ChatGPT打字机回复',
        route: '/chat',
        color: Colors.green,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: examples.length,
      itemBuilder: (context, index) {
        final item = examples[index];
        return _buildExampleCard(context, item);
      },
    );
  }

  /// 构建示例卡片
  Widget _buildExampleCard(BuildContext context, _ExampleItem item) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(item.route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 24,
                ),
              ),
              const Spacer(),
              Text(
                item.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建状态概览卡片
  Widget _buildStatusCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusTile(
              context,
              icon: Icons.palette,
              title: l10n.currentTheme,
              value: Consumer<ThemeProvider>(
                builder: (context, provider, _) =>
                    Text(provider.currentTheme.displayName),
              ),
            ),
            const Divider(),
            _buildStatusTile(
              context,
              icon: Icons.language,
              title: l10n.currentLanguage,
              value: Consumer<LocaleProvider>(
                builder: (context, provider, _) =>
                    Text(provider.currentLocale.displayName),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建状态行
  Widget _buildStatusTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(title),
          const Spacer(),
          DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            child: value,
          ),
        ],
      ),
    );
  }
}

/// 示例项数据类
class _ExampleItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final Color color;

  const _ExampleItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.color,
  });
}
