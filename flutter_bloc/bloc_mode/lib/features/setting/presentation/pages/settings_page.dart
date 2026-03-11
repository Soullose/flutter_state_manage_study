import 'package:bloc_mode/core/style/bloc/theme_bloc.dart';
import 'package:bloc_mode/core/l10n/bloc/locale_bloc.dart';
import 'package:bloc_mode/features/auth/bloc/auth_bloc.dart';
import 'package:bloc_mode/features/auth/bloc/auth_event.dart';
import 'package:bloc_mode/features/setting/presentation/bloc/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// 设置页面
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(),
      child: const SettingsView(),
    );
  }
}

/// 设置视图
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLoggedOut());
              context.go('/login');
            },
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ThemeSelector(),
            SizedBox(height: 24),
            LanguageSelector(),
            SizedBox(height: 24),
            AboutSection(),
          ],
        ),
      ),
    );
  }
}

/// 主题选择器
class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final currentThemeMode = themeState.themeMode;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('主题设置', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildThemeOption(
                    '跟随系统',
                    Icons.brightness_auto,
                    ThemeMode.system,
                    currentThemeMode == ThemeMode.system,
                    context,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildThemeOption(
                    '浅色模式',
                    Icons.light_mode,
                    ThemeMode.light,
                    currentThemeMode == ThemeMode.light,
                    context,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildThemeOption(
                    '深色模式',
                    Icons.dark_mode,
                    ThemeMode.dark,
                    currentThemeMode == ThemeMode.dark,
                    context,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    String title,
    IconData icon,
    ThemeMode themeMode,
    bool isSelected,
    BuildContext context,
  ) {
    return InkWell(
      onTap: () {
        context.read<ThemeBloc>().add(ThemeChangedTo(themeMode));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            color: isSelected ? Theme.of(context).colorScheme.onPrimary : null,
          ),
        ),
      ),
    );
  }
}

/// 语言选择器
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final localeState = context.watch<LocaleBloc>().state;
    final currentLocale = localeState.locale;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('语言设置', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildLanguageOption(
                    '简体中文',
                    'zh',
                    currentLocale.languageCode == 'zh',
                    context,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildLanguageOption(
                    'English',
                    'en',
                    currentLocale.languageCode == 'en',
                    context,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    String title,
    String languageCode,
    bool isSelected,
    BuildContext context,
  ) {
    return InkWell(
      onTap: () {
        context.read<LocaleBloc>().add(
          LocaleChanged(
            Locale(languageCode, languageCode == 'zh' ? 'CN' : 'US'),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// 关于部分
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('关于', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('版本'),
              subtitle: Text('1.0.0'),
            ),
            const ListTile(
              leading: Icon(Icons.code),
              title: Text('技术栈'),
              subtitle: Text('Flutter + Bloc + GoRouter'),
            ),
          ],
        ),
      ),
    );
  }
}
