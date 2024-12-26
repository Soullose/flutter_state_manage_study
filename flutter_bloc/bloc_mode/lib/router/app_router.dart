import 'package:bloc_mode/app.dart';
import 'package:bloc_mode/counter/view/bloc/counter_page.dart';
import 'package:bloc_mode/counter/view/cubit/count/counter_cubit_page.dart';
import 'package:bloc_mode/main_wrapper/view/main_wrapper_page.dart';
import 'package:bloc_mode/timer/view/timer_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final _oneNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'one');
  static final _twoNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'two');
  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/one',
    routes: <RouteBase>[
      // GoRoute(
      //   path: '/',
      //   builder: (context, state) => const AppPage(),
      //   routes: <RouteBase>[
      //     GoRoute(
      //       path: 'blocCount',
      //       builder: (context, state) => const CounterPage(),
      //     ),
      //     GoRoute(
      //       path: 'cubitCount',
      //       builder: (context, state) => const CounterCubitPage(),
      //     ),
      //     GoRoute(
      //       path: 'blocTimer',
      //       pageBuilder: (context, state) => CustomTransitionPage(
      //         child: const TimerPage(),
      //         transitionsBuilder:
      //             (context, animation, secondaryAnimation, child) {
      //           const begin = Offset(0.0, 1.0);
      //           const end = Offset.zero;
      //           const curve = Curves.ease;
      //
      //           var tween = Tween(begin: begin, end: end)
      //               .chain(CurveTween(curve: curve));
      //
      //           return SlideTransition(
      //             position: animation.drive(tween),
      //             child: child,
      //           );
      //         },
      //       ),
      //     ),
      //   ],
      // ),
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          // Return the widget that implements the custom shell (in this case
          // using a BottomNavigationBar). The StatefulNavigationShell is passed
          // to be able access the state of the shell and to navigate to other
          // branches in a stateful way.
          return MainWrapperPage(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            navigatorKey: _oneNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: '/one',
                builder: (context, state) => const AppPage(),
                routes: [
                  GoRoute(
                    path: 'blocCount',
                    builder: (context, state) => const CounterPage(),
                  ),
                  GoRoute(
                    path: 'cubitCount',
                    builder: (context, state) => const CounterCubitPage(),
                  ),
                  GoRoute(
                    path: 'blocTimer',
                    pageBuilder: (context, state) => CustomTransitionPage(
                      child: const TimerPage(),
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
          ),
          StatefulShellBranch(
            navigatorKey: _twoNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: '/two',
                builder: (context, state) => const CounterPage(),
              ),
            ],
          ),
        ],
      )
    ],
  );

// GoRouter routes() {
//   return GoRouter(routes: routes,refreshListenable: );
// }

  static GoRouter get router => _router;
}
