import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../common/widgets/main_shell.dart';
import '../core/error_log/models/error_log_entry.dart';
import '../features/chat/presentation/pages/chat_page.dart';
import '../features/timer/presentation/pages/timer_page.dart';
import '../features/theme/pages/theme_settings_page.dart';
import '../features/profile/pages/profile_page.dart';
import '../features/profile/pages/privacy_page.dart';
import '../features/profile/pages/user_agreement_page.dart';
import '../features/profile/pages/licenses_page.dart';
import '../features/error_log/pages/error_log_page.dart';
import '../features/error_log/pages/error_log_detail_page.dart';
import '../features/tts/pages/tts_page.dart';
import '../features/tts/pages/tts_models_page.dart';
import 'index.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: <RouteBase>[
      /// ShellRoute 用于底部导航栏，只包含首页和我的页面
      /// 子路由放在 ShellRoute 外部，这样子页面不会显示底部导航栏
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          /// 首页（不带子路由）
          GoRoute(path: '/', builder: (context, state) => const AppPage()),

          /// 我的页面（不带子路由）
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),

      /// 首页的子路由（独立路由，不显示底部导航栏）
      GoRoute(
        path: '/riverpodCounter',
        pageBuilder: _buildSlideTransitionPage(const CounterPage()),
      ),
      GoRoute(
        path: '/riverpodSetting',
        pageBuilder: _buildSlideTransitionPage(const SettingView()),
      ),
      GoRoute(
        path: '/riverpodTimer',
        pageBuilder: _buildSlideTransitionPage(const TimerPage()),
      ),
      GoRoute(
        path: '/themeSettings',
        pageBuilder: _buildSlideTransitionPage(const ThemeSettingsPage()),
      ),

      /// TTS 语音合成路由
      GoRoute(
        path: '/tts',
        pageBuilder: _buildSlideTransitionPage(const TtsPage()),
      ),
      GoRoute(
        path: '/tts/models',
        pageBuilder: _buildSlideTransitionPage(const TtsModelsPage()),
      ),

      /// 聊天路由
      GoRoute(
        path: '/chat',
        pageBuilder: _buildSlideTransitionPage(const ChatPage()),
      ),

      /// 我的页面的子路由（独立路由，不显示底部导航栏）
      GoRoute(
        path: '/profile/privacy',
        pageBuilder: _buildSlideTransitionPage(const PrivacyPage()),
      ),
      GoRoute(
        path: '/profile/agreement',
        pageBuilder: _buildSlideTransitionPage(const UserAgreementPage()),
      ),
      GoRoute(
        path: '/profile/licenses',
        pageBuilder: _buildSlideTransitionPage(const LicensesPage()),
      ),

      /// 错误日志页面
      GoRoute(
        path: '/errorLog',
        pageBuilder: _buildSlideTransitionPage(const ErrorLogPage()),
      ),
      GoRoute(
        path: '/errorLog/:id',
        pageBuilder: (context, state) {
          final log = state.extra as ErrorLogEntry?;
          if (log == null) {
            return CustomTransitionPage(
              child: Scaffold(
                appBar: AppBar(title: const Text('错误')),
                body: const Center(child: Text('未找到错误日志')),
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            );
          }
          return CustomTransitionPage(
            child: ErrorLogDetailPage(log: log),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;
                  final tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
          );
        },
      ),
    ],
  );

  /// 构建滑动过渡动画页面
  static Page<void> Function(BuildContext, GoRouterState)
  _buildSlideTransitionPage(Widget child) {
    return (context, state) => CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  static GoRouter get router => _router;
}
