import 'package:bloc_mode/app.dart';
import 'package:bloc_mode/features/chat/presentation/view/chat_page.dart';
import 'package:bloc_mode/features/counter/view/bloc/counter_page.dart';
import 'package:bloc_mode/features/counter/view/cubit/count/counter_cubit_page.dart';
import 'package:bloc_mode/features/main_wrapper/view/main_wrapper_page.dart';
import 'package:bloc_mode/features/mqtt_client/view/mqtt_client_page.dart';
import 'package:bloc_mode/features/timer/view/timer_page.dart';
import 'package:bloc_mode/features/setting/presentation/pages/settings_page.dart';
import 'package:bloc_mode/core/di/injector.dart';
import 'package:bloc_mode/core/utils/app_logger.dart';
import 'package:bloc_mode/features/auth/bloc/auth_bloc.dart';
import 'package:bloc_mode/features/auth/bloc/auth_state.dart';
import 'package:bloc_mode/features/auth/view/login_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'go_router_refresh_stream.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'root',
  );
  static final _oneNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'one');
  static final _twoNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'two');

  /// 创建带认证守卫的路由
  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      observers: <NavigatorObserver>[MyNavObserver()],
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/one',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthenticated = authState is Authenticated;
        final isGoingToLogin = state.matchedLocation == '/login';

        // 未认证且不是去登录页，重定向到登录页
        if (!isAuthenticated && !isGoingToLogin) {
          return '/login';
        }

        // 已认证且去登录页，重定向到首页
        if (isAuthenticated && isGoingToLogin) {
          return '/one';
        }

        return null; // 无需重定向
      },
      // 自定义错误页面
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('页面未找到')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 24),
                Text(
                  '抱歉，页面未找到',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  '路径: ${state.matchedLocation}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.error.toString(),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => context.go('/one'),
                  icon: const Icon(Icons.home),
                  label: const Text('返回首页'),
                ),
              ],
            ),
          ),
        ),
      ),
      routes: <RouteBase>[
        // 登录页面（无需认证）
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        // 设置页面（需要认证）
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
        // 主界面（需要认证）
        StatefulShellRoute.indexedStack(
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state, navigationShell) {
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
                        barrierDismissible: true,
                        opaque: false,
                        barrierColor: Colors.black38,
                        transitionDuration: const Duration(milliseconds: 300),
                        reverseTransitionDuration: const Duration(
                          milliseconds: 200,
                        ),
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
                      path: 'blocMqtt',
                      builder: (context, state) => const MqttClientPage(),
                    ),
                    GoRoute(
                      path: 'chat',
                      builder: (context, state) => const ChatPage(),
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
        ),
      ],
    );
  }

  /// 获取默认路由器（用于无认证的示例）
  static final GoRouter _defaultRouter = createRouter(injector<AuthBloc>());

  static GoRouter get router => _defaultRouter;
}

/// The Navigator observer.
class MyNavObserver extends NavigatorObserver {
  /// Creates a [MyNavObserver].
  MyNavObserver();

  /// 全局日志实例
  ///
  /// 使用 [AppLogger.logger] 统一配置，在 release 模式下自动过滤 debug 级别日志
  final log = AppLogger.logger;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    log.d('didPush: ${route.str}, previousRoute= ${previousRoute?.str}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      log.d('didPop: ${route.str}, previousRoute= ${previousRoute?.str}');

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      log.d('didRemove: ${route.str}, previousRoute= ${previousRoute?.str}');

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      log.d('didReplace: new= ${newRoute?.str}, old= ${oldRoute?.str}');
}

extension on Route<dynamic> {
  String get str => 'route(${settings.name}: ${settings.arguments})';
}
