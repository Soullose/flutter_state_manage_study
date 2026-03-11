# bloc_mode

一个 Flutter Bloc 学习示例项目，展示了如何使用 Flutter Bloc 进行状态管理。

## 项目结构

```
lib/
├── core/
│   ├── di/
│   │   └── injector.dart          # 依赖注入配置
│   ├── l10n/
│   │   └── bloc/
│   │       ├── locale_bloc.dart
│   │       ├── locale_event.dart
│   │       └── locale_state.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── go_router_refresh_stream.dart
│   ├── storage/
│   │   ├── shared_preferences_service.dart
│   │   └── shared_preferences_utils.dart
│   └── style/
│       └── bloc/
│           ├── theme_bloc.dart
│           ├── theme_event.dart
│           └── theme_state.dart
├── features/
│   ├── auth/
│   │   ├── bloc/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   ├── models/
│   │   │   └── user.dart
│   │   ├── repositories/
│   │   │   └── auth_repository.dart
│   │   └── view/
│   │       ├── login_page.dart
│   │       └── login_view.dart
│   ├── counter/
│   ├── setting/
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── settings_bloc.dart
│   │       │   ├── settings_event.dart
│   │       │   └── settings_state.dart
│   │       └── pages/
│   │           └── settings_page.dart
│   └── timer/
├── main.dart
└── app.dart
```

## 主要功能

### 1. 主题切换
- 使用 `ThemeBloc` 实现主题的切换（浅色/深色/跟随系统）
- 通过设置页面的主题选择器组件进行切换
- 主题状态会持久化到本地存储
- 支持三种主题模式：浅色、深色、跟随系统

### 2. 多语言支持
- 使用 `LocaleBloc` 实现中英文切换
- 通过设置页面的语言选择器组件进行切换
- 语言设置会持久化到本地存储
- 支持中文和英文

### 3. 认证系统
- 使用 `AuthBloc` 管理认证状态
- 支持登录、登出功能
- 登录页面使用 `AuthRepository` 进行登录验证
- 使用 `SharedPreferencesUtils` 持久化登录状态
- 支持模拟登录（实际项目中应该调用 API）

### 4. 路由守卫
- 使用 `GoRouter` + `AuthBloc` 实现路由守卫
- 未认证用户自动重定向到登录页
- 已认证用户访问登录页自动重定向到首页
- 使用 `GoRouterRefreshStream` 监听认证状态变化
- 自动刷新路由

### 5. 设置页面
- 使用 `SettingsBloc` 管理设置状态
- 包含主题选择器、语言选择器、关于信息
- 登出按钮调用 `AuthBloc` 的登出功能

## 技术栈

- Flutter 3.41.x
- flutter_bloc 9.1.1
- go_router 16.2.4
- equatable 2.0.5
- shared_preferences 2.3.0
- logger 2.0.2

## 依赖注入

所有 Bloc 都通过 GetIt 进行依赖注入：

```dart
// 全局 Bloc - 单例模式
injector.registerLazySingleton<ThemeBloc>(() => ThemeBloc(prefs: injector()));
injector.registerLazySingleton<LocaleBloc>(() => LocaleBloc(prefs: injector()));
injector.registerLazySingleton<AuthBloc>(() => AuthBloc(authRepository: injector()));

// 认证相关
injector.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(prefs: injector()),
);
```

## 使用方法

### 主题切换
```dart
// 在任何地方切换主题
context.read<ThemeBloc>().add(const ThemeToggled());
// 或设置指定主题
context.read<ThemeBloc>().add(ThemeChangedTo(ThemeMode.dark));
```

### 语言切换
```dart
// 切换语言
context.read<LocaleBloc>().add(LocaleChanged(const Locale('en', 'US')));
```

### 认证相关
```dart
// 登录
context.read<AuthBloc>().add(AuthLoggedIn('username', 'password'));

// 登出
context.read<AuthBloc>().add(const AuthLoggedOut());
```

## 路由配置

```dart
// 路由守卫示例
GoRouter(
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

    return null;
  },
  routes: [...],
);
```

## 注意事项

1. 所有 Bloc 都需要在 `injector.dart` 中注册
2. 主题和语言设置会自动持久化到本地存储
3. 路由守卫依赖于 `AuthBloc` 的状态
4. 登录页面需要使用 `BlocProvider` 提供 `AuthBloc`
5. 设置页面需要使用 `BlocProvider` 提供 `SettingsBloc`

## 示例页面

### 登录页面
- 用户名和密码输入框
- 登录按钮
- 登录状态显示（加载中/成功/失败）

### 设置页面
- 主题选择器（跟随系统/浅色/深色）
- 语言选择器（中文/英文）
- 关于信息
- 登出按钮

## 首页功能

- 基础示例分组
  - Bloc 计数器
  - Cubit 计数器
  - Bloc 定时器
- 网络示例分组
  - MQTT 客户端
- 系统功能分组
  - 主题切换
  - 语言切换
  - 设置入口
- 用户信息显示
- 登出按钮

## 最佳实践

1. 使用 sealed class 定义状态和事件基类
2. 使用 Equatable 进行状态比较
3. 使用 part 指令组织代码结构
4. 持久化重要设置到本地存储
5. 路由守卫使用 refreshListenable 自动刷新
