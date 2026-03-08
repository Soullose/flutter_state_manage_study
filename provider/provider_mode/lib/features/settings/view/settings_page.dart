import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_mode/features/settings/settings_provider.dart';

/// 应用设置页面
///
/// 展示如何使用Provider管理复杂对象状态
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('应用设置'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '重置为默认',
            onPressed: () => _showResetDialog(context),
          ),
        ],
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          final settings = settingsProvider.settings;

          return ListView(
            children: [
              // 通知设置分组
              _buildSectionHeader(context, '通知设置'),
              _buildSwitchTile(
                context,
                icon: Icons.notifications,
                title: '推送通知',
                subtitle: '接收应用推送消息',
                value: settings.notificationsEnabled,
                onChanged: (_) => settingsProvider.toggleNotifications(),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.volume_up,
                title: '声音',
                subtitle: '播放提示音',
                value: settings.soundEnabled,
                onChanged: (_) => settingsProvider.toggleSound(),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.vibration,
                title: '振动',
                subtitle: '触觉反馈',
                value: settings.vibrationEnabled,
                onChanged: (_) => settingsProvider.toggleVibration(),
              ),

              const Divider(height: 32),

              // 隐私设置分组
              _buildSectionHeader(context, '隐私设置'),
              _buildSwitchTile(
                context,
                icon: Icons.update,
                title: '自动检查更新',
                subtitle: '启动时检查新版本',
                value: settings.autoUpdateCheck,
                onChanged: (_) => settingsProvider.toggleAutoUpdateCheck(),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.analytics,
                title: '数据统计',
                subtitle: '帮助改进应用体验',
                value: settings.analyticsEnabled,
                onChanged: (_) => settingsProvider.toggleAnalytics(),
              ),

              const Divider(height: 32),

              // 存储设置分组
              _buildSectionHeader(context, '存储'),
              _buildCacheTile(context, settingsProvider),

              const Divider(height: 32),

              // 说明卡片
              _buildInfoCard(context),
            ],
          );
        },
      ),
    );
  }

  /// 构建分组标题
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  /// 构建开关选项
  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
      onTap: () => onChanged(!value),
    );
  }

  /// 构建缓存清理选项
  Widget _buildCacheTile(BuildContext context, SettingsProvider provider) {
    return ListTile(
      leading: const Icon(Icons.cleaning_services),
      title: const Text('清理缓存'),
      subtitle: Text('当前缓存: ${provider.settings.cacheSizeMB} MB'),
      trailing: TextButton(
        onPressed: provider.settings.cacheSizeMB > 0
            ? () => _showClearCacheDialog(context, provider)
            : null,
        child: const Text('清理'),
      ),
      onTap: () => provider.calculateCacheSize(),
    );
  }

  /// 构建说明卡片
  Widget _buildInfoCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
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
                  '复杂状态管理说明',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '''• AppSettings 使用 Equatable 方便比较
• 使用 copyWith 创建不可变对象的副本
• 设置以JSON格式持久化存储
• 每次修改都会保存到本地''',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示重置确认对话框
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置设置'),
        content: const Text('确定要将所有设置恢复为默认值吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              context.read<SettingsProvider>().resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('设置已重置')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示清理缓存确认对话框
  void _showClearCacheDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清理缓存'),
        content: const Text('确定要清理所有缓存数据吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              // 显示加载指示器
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              await provider.clearCache();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('缓存已清理')),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
