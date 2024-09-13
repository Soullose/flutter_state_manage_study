import 'package:bloc_mode/app.dart';
import 'package:bloc_mode/counter/view/counter_page.dart';
import 'package:bloc_mode/counter/view/cubit/count/counter_cubit_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            path: 'blocCount',
            builder: (context, state) => const CounterPage(),
          ),
          GoRoute(
            path: 'cubitCount',
            builder: (context, state) => const CounterCubitPage(),
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
