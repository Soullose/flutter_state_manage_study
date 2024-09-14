import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider_mode/app.dart';
import 'package:provider_mode/counter/view/counter_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const AppPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
        routes: <RouteBase>[
          GoRoute(
            path: 'providerCounter',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const CounterPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          )
        ],
      ),
    ],
  );

  static GoRouter get router => _router;
}
