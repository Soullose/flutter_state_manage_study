import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider_mode/app.dart';
import 'package:provider_mode/features/auth/presentation/view/login_page.dart';
import 'package:provider_mode/features/chat/presentation/view/chat_page.dart';
import 'package:provider_mode/features/counter/view/counter_page.dart';
import 'package:provider_mode/features/locale/view/locale_page.dart';
import 'package:provider_mode/features/logs/view/logs_page.dart';
import 'package:provider_mode/features/mqtt/view/mqtt_page.dart';
import 'package:provider_mode/features/settings/view/settings_page.dart';
import 'package:provider_mode/features/theme/view/theme_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// 暴露 navigatorKey 给外部使用（如 SnackBar）
  static GlobalKey<NavigatorState> get navigatorKey => _rootNavigatorKey;

  /// 页面转场动画构建器
  static Widget _slideTransition(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.ease;

    var tween = Tween(
      begin: begin,
      end: end,
    ).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const AppPage(),
          transitionsBuilder: _slideTransition,
        ),
        routes: <RouteBase>[
          GoRoute(
            path: 'providerCounter',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const CounterPage(),
              transitionsBuilder: _slideTransition,
            ),
          ),
          GoRoute(
            path: 'theme',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const ThemePage(),
              transitionsBuilder: _slideTransition,
            ),
          ),
          GoRoute(
            path: 'locale',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const LocalePage(),
              transitionsBuilder: _slideTransition,
            ),
          ),
          GoRoute(
            path: 'settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const SettingsPage(),
              transitionsBuilder: _slideTransition,
            ),
          ),
          GoRoute(
            path: 'logs',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const LogsPage(),
              transitionsBuilder: _slideTransition,
            ),
          ),
          // Auth 认证示例
          GoRoute(
            path: 'auth',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const LoginPage(),
              transitionsBuilder: _slideTransition,
            ),
          ),
          // MQTT 状态查看
          GoRoute(
            path: 'mqtt',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const MqttPage(),
              transitionsBuilder: _slideTransition,
            ),
          ),
          // Chat 流式聊天（仿 ChatGPT 打字机回复）
          GoRoute(
            path: 'chat',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const ChatPage(),
              transitionsBuilder: _slideTransition,
            ),
          ),
        ],
      ),
    ],
  );

  static GoRouter get router => _router;
}
