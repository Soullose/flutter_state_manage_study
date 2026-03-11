import 'package:bloc_mode/core/style/bloc/theme_bloc.dart';
import 'package:bloc_mode/features/auth/bloc/auth_bloc.dart';
import 'package:bloc_mode/features/auth/bloc/auth_event.dart';
import 'package:bloc_mode/features/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// 应用首页
class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Bloc 学习示例'),
        centerTitle: true,
        actions: [
          // 主题切换快捷按钮
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () {
                  context.read<ThemeBloc>().add(const ThemeToggled());
                },
              );
            },
          ),
          // 设置按钮
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 基础示例分组
          _SectionHeader(title: '基础示例'),
          _ExampleCard(
            title: 'Bloc 计数器',
            subtitle: '使用 Bloc 模式实现的加减计数器',
            icon: Icons.add_circle,
            route: '/one/blocCount',
          ),
          _ExampleCard(
            title: 'Cubit 计数器',
            subtitle: '使用 Cubit 模式实现的加减计数器',
            icon: Icons.add_circle_outline,
            route: '/one/cubitCount',
          ),
          _ExampleCard(
            title: 'Bloc 定时器',
            subtitle: '使用 Bloc 模式实现的倒计时定时器',
            icon: Icons.timer,
            route: '/one/blocTimer',
          ),

          const SizedBox(height: 24),

          // 网络示例分组
          _SectionHeader(title: '网络示例'),
          _ExampleCard(
            title: 'MQTT 客户端',
            subtitle: '使用 Bloc 模式实现的 MQTT 连接',
            icon: Icons.cloud_queue,
            route: '/one/blocMqtt',
          ),

          const SizedBox(height: 24),

          // 系统功能分组
          _SectionHeader(title: '系统功能'),
          _ExampleCard(
            title: '设置',
            subtitle: '主题切换、语言设置等',
            icon: Icons.settings_applications,
            route: '/settings',
          ),
        ],
      ),
      // 显示当前用户信息
      bottomNavigationBar: _buildUserInfo(context),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(child: Text(state.user.username[0].toUpperCase())),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.user.username,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        state.user.email ?? '未设置邮箱',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLoggedOut());
                    context.go('/login');
                  },
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// 分组标题
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// 示例卡片
class _ExampleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? route;

  const _ExampleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: route != null ? () => context.push(route!) : null,
      ),
    );
  }
}
