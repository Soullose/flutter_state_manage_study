import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../counter/view/counter_page.dart';

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

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

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