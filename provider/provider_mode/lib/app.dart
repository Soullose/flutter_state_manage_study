import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider_mode/features/locale/locale_provider.dart';
import 'package:provider_mode/features/theme/theme_provider.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider状态管理学习'),
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
            tooltip: '切换主题',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 欢迎卡片
          _buildWelcomeCard(context),
          const SizedBox(height: 24),

          // 功能示例分组
          _buildSectionHeader(context, 'Provider示例'),
          const SizedBox(height: 12),
          _buildExampleGrid(context),

          const SizedBox(height: 24),

          // 状态概览
          _buildSectionHeader(context, '当前状态'),
          const SizedBox(height: 12),
          _buildStatusCard(context),
        ],
      ),
    );
  }

  /// 构建欢迎卡片
  Widget _buildWelcomeCard(BuildContext context) {
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
              '欢迎学习Provider状态管理',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击下方卡片探索不同的Provider使用场景',
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
  Widget _buildExampleGrid(BuildContext context) {
    final examples = [
      _ExampleItem(
        icon: Icons.calculate,
        title: '计数器',
        subtitle: '基础状态管理',
        route: '/providerCounter',
        color: Colors.blue,
      ),
      _ExampleItem(
        icon: Icons.palette,
        title: '主题切换',
        subtitle: '亮色/暗色/系统',
        route: '/theme',
        color: Colors.purple,
      ),
      _ExampleItem(
        icon: Icons.language,
        title: '多语言',
        subtitle: '中文/English',
        route: '/locale',
        color: Colors.orange,
      ),
      _ExampleItem(
        icon: Icons.settings,
        title: '应用设置',
        subtitle: '复杂对象管理',
        route: '/settings',
        color: Colors.teal,
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
                  color: item.color.withOpacity(0.1),
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
  Widget _buildStatusCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusTile(
              context,
              icon: Icons.palette,
              title: '当前主题',
              value: Consumer<ThemeProvider>(
                builder: (context, provider, _) =>
                    Text(provider.currentTheme.displayName),
              ),
            ),
            const Divider(),
            _buildStatusTile(
              context,
              icon: Icons.language,
              title: '当前语言',
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
