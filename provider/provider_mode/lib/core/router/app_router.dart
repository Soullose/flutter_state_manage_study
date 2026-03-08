import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider_mode/app.dart';
import 'package:provider_mode/features/counter/view/counter_page.dart';
import 'package:provider_mode/features/locale/view/locale_page.dart';
import 'package:provider_mode/features/settings/view/settings_page.dart';
import 'package:provider_mode/features/theme/view/theme_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

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
        ],
      ),
    ],
  );

  static GoRouter get router => _router;
}
