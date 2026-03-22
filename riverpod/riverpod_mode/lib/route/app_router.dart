import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../features/timer/presentation/pages/timer_page.dart';
import '../features/theme/pages/theme_settings_page.dart';
import 'index.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const AppPage(),
        routes: <RouteBase>[
          GoRoute(
            path: 'riverpodCounter',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const CounterPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
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
                  },
            ),
          ),
          GoRoute(
            path: 'riverpodSetting',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const SettingView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
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
                  },
            ),
          ),
          GoRoute(
            path: 'riverpodTimer',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const TimerPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
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
                  },
            ),
          ),
          GoRoute(
            path: 'themeSettings',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const ThemeSettingsPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
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
                  },
            ),
          ),
        ],
      ),
    ],
  );

  // GoRouter routes() {
  //   return GoRouter(routes: routes,refreshListenable: );
  // }

  static GoRouter get router => _router;
}
