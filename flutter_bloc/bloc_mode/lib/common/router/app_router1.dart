// import 'package:animations/animations.dart';
// import 'package:bloc_mode/app.dart';
// import 'package:bloc_mode/counter/view/bloc/counter_page.dart';
// import 'package:bloc_mode/counter/view/cubit/count/counter_cubit_page.dart';
// import 'package:bloc_mode/main_wrapper/view/main_wrapper_page.dart';
// import 'package:bloc_mode/timer/view/timer_page.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:logger/logger.dart';
//
// class AppRouter {
//   static final _rootNavigatorKey =
//   GlobalKey<NavigatorState>(debugLabel: 'root');
//   static final _oneNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'one');
//   static final _twoNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'two');
//   static final GoRouter _router = GoRouter(
//     observers: <NavigatorObserver>[MyNavObserver()],
//     navigatorKey: _rootNavigatorKey,
//     initialLocation: '/one',
//     routes: <RouteBase>[
//       ShellRoute(
//         parentNavigatorKey: _rootNavigatorKey,
//         branches: <StatefulShellBranch>[
//           StatefulShellBranch(
//             navigatorKey: _oneNavigatorKey,
//             routes: <RouteBase>[
//               GoRoute(
//                 path: '/one',
//                 // builder: (context, state) => const AppPage(),
//                 pageBuilder: (context, state) => CustomTransitionPage(
//                   key: state.pageKey,
//                   child: const AppPage(),
//                   transitionsBuilder: (BuildContext context,
//                       Animation<double> animation,
//                       Animation<double> secondaryAnimation,
//                       Widget child) {
//                     return FadeThroughTransition(
//                       fillColor: Colors.transparent,
//                       animation: animation,
//                       secondaryAnimation: secondaryAnimation,
//                       child: child,
//                     );
//                   },
//                 ),
//                 routes: [
//                   GoRoute(
//                     path: 'blocCount',
//                     // builder: (context, state) => const CounterPage(),
//                     pageBuilder: (context, state) => CustomTransitionPage(
//                       key: state.pageKey,
//                       child: const CounterPage(),
//                       transitionsBuilder: (BuildContext context,
//                           Animation<double> animation,
//                           Animation<double> secondaryAnimation,
//                           Widget child) {
//                         return FadeThroughTransition(
//                           fillColor: Colors.transparent,
//                           animation: animation,
//                           secondaryAnimation: secondaryAnimation,
//                           child: child,
//                         );
//                       },
//                     ),
//                   ),
//                   GoRoute(
//                     path: 'cubitCount',
//                     builder: (context, state) => const CounterCubitPage(),
//                   ),
//                   GoRoute(
//                     path: 'blocTimer',
//                     pageBuilder: (context, state) => CustomTransitionPage(
//                       child: const TimerPage(),
//                       barrierDismissible: true,
//                       opaque: false,
//                       barrierColor: Colors.black38,
//                       transitionDuration: const Duration(milliseconds: 500),
//                       reverseTransitionDuration:
//                       const Duration(milliseconds: 200),
//                       transitionsBuilder:
//                           (context, animation, secondaryAnimation, child) {
//                         const begin = Offset(0.0, 1.0);
//                         const end = Offset.zero;
//                         const curve = Curves.ease;
//
//                         var tween = Tween(begin: begin, end: end)
//                             .chain(CurveTween(curve: curve));
//                         return FadeTransition(opacity: animation, child: child);
//                         // return SlideTransition(
//                         //   position: animation.drive(tween),
//                         //   child: child,
//                         // );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           StatefulShellBranch(
//             navigatorKey: _twoNavigatorKey,
//             routes: <RouteBase>[
//               GoRoute(
//                 path: '/two',
//                 builder: (context, state) => const CounterPage(),
//               ),
//             ],
//           ),
//         ], routes: <RouteBase>[
//
//       ],
//       ),
//     ],
//   );
//
// // GoRouter routes() {
// //   return GoRouter(routes: routes,refreshListenable: );
// // }
//
//   static GoRouter get router => _router;
// }
//
// /// The Navigator observer.
// class MyNavObserver extends NavigatorObserver {
//   /// Creates a [MyNavObserver].
//   MyNavObserver() {
//     // Logger.onRecord.listen((e) => debugPrint('$e'));
//   }
//
//   /// The logged message.
//   final Logger log = Logger();
//
//   @override
//   void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
//     log.i('didPush: ${route.str}, previousRoute= ${previousRoute?.str}');
//   }
//
//   @override
//   void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
//       log.i('didPop: ${route.str}, previousRoute= ${previousRoute?.str}');
//
//   @override
//   void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
//       log.i('didRemove: ${route.str}, previousRoute= ${previousRoute?.str}');
//
//   @override
//   void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
//       log.i('didReplace: new= ${newRoute?.str}, old= ${oldRoute?.str}');
// }
//
// extension on Route<dynamic> {
//   String get str => 'route(${settings.name}: ${settings.arguments})';
// }
