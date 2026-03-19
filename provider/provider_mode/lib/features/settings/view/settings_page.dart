import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_mode/features/settings/settings_provider.dart';
import 'package:provider_mode/l10n/app_localizations.dart';

/// 应用设置页面
///
/// 展示如何使用Provider管理复杂对象状态
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appSettings),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.resetToDefault,
            onPressed: () => _showResetDialog(context, l10n),
          ),
        ],
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          final settings = settingsProvider.settings;

          return ListView(
            children: [
              // 通知设置分组
              _buildSectionHeader(context, l10n.notificationSettings),
              _buildSwitchTile(
                context,
                icon: Icons.notifications,
                title: l10n.pushNotification,
                subtitle: l10n.pushNotificationSubtitle,
                value: settings.notificationsEnabled,
                onChanged: (_) => settingsProvider.toggleNotifications(),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.volume_up,
                title: l10n.sound,
                subtitle: l10n.soundSubtitle,
                value: settings.soundEnabled,
                onChanged: (_) => settingsProvider.toggleSound(),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.vibration,
                title: l10n.vibration,
                subtitle: l10n.vibrationSubtitle,
                value: settings.vibrationEnabled,
                onChanged: (_) => settingsProvider.toggleVibration(),
              ),

              const Divider(height: 32),

              // 隐私设置分组
              _buildSectionHeader(context, l10n.privacySettings),
              _buildSwitchTile(
                context,
                icon: Icons.update,
                title: l10n.autoUpdateCheck,
                subtitle: l10n.autoUpdateCheckSubtitle,
                value: settings.autoUpdateCheck,
                onChanged: (_) => settingsProvider.toggleAutoUpdateCheck(),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.analytics,
                title: l10n.analytics,
                subtitle: l10n.analyticsSubtitle,
                value: settings.analyticsEnabled,
                onChanged: (_) => settingsProvider.toggleAnalytics(),
              ),

              const Divider(height: 32),

              // 存储设置分组
              _buildSectionHeader(context, l10n.storage),
              _buildCacheTile(context, settingsProvider, l10n),

              const Divider(height: 32),

              // 说明卡片
              _buildInfoCard(context, l10n),
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
  Widget _buildCacheTile(
      BuildContext context, SettingsProvider provider, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.cleaning_services),
      title: Text(l10n.cache),
      subtitle: Text(l10n.cacheSize(provider.settings.cacheSizeMB)),
      trailing: TextButton(
        onPressed: provider.settings.cacheSizeMB > 0
            ? () => _showClearCacheDialog(context, provider, l10n)
            : null,
        child: Text(l10n.clearCacheButton),
      ),
      onTap: () => provider.calculateCacheSize(),
    );
  }

  /// 构建说明卡片
  Widget _buildInfoCard(BuildContext context, AppLocalizations l10n) {
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
                  l10n.complexStateManagementInfo,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.complexStateManagementDetails,
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
  void _showResetDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetSettings),
        content: Text(l10n.resetSettingsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              context.read<SettingsProvider>().resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.settingsReset)),
              );
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  /// 显示清理缓存确认对话框
  void _showClearCacheDialog(
      BuildContext context, SettingsProvider provider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCacheTitle),
        content: Text(l10n.clearCacheConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
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
                  SnackBar(content: Text(l10n.cacheCleared)),
                );
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}
