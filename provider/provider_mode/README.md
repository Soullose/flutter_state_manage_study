# Provider Mode - Flutter状态管理学习项目

一个用于学习Flutter Provider状态管理的示例项目，展示了多种常见的状态管理场景。

## 功能特性

### 🎯 Provider示例

| 示例 | 说明 | 学习要点 |
|------|------|---------|
| **计数器** | 基础计数功能 | ChangeNotifier基础用法、状态持久化 |
| **主题切换** | 亮色/暗色/系统跟随 | 与MaterialApp集成、枚举状态管理 |
| **多语言** | 中文/英文切换 | 国际化支持、Locale管理 |
| **应用设置** | 通知/声音/振动开关 | 复杂对象状态管理、Equatable使用 |

### 🏗️ 项目架构

```
lib/
├── main.dart                 # 应用入口，全局Provider配置
├── app.dart                  # 首页
├── core/                     # 核心基础设施
│   ├── router/              # 路由配置 (go_router)
│   ├── store/               # 存储服务 (SharedPreferences, MMKV)
│   ├── mqtt/                # MQTT服务 (事件驱动架构)
│   ├── event/               # 事件总线
│   └── error/               # 错误处理
├── di/                       # 依赖注入 (GetIt)
└── features/                 # 功能模块
    ├── counter/             # 计数器示例
    ├── theme/               # 主题切换示例
    ├── locale/              # 多语言示例
    ├── settings/            # 应用设置示例
    └── auth/                # 认证模块 (Clean Architecture)
```

## 技术栈

- **Flutter**: 3.41.x
- **Dart**: 3.11
- **状态管理**: provider 6.1.5+1
- **路由**: go_router 16.2.4
- **依赖注入**: get_it 9.1.1
- **存储**: shared_preferences, mmkv
- **网络**: dio 5.9.0
- **MQTT**: mqtt_client 10.11.1

## 快速开始

### 环境要求

- Flutter SDK >= 3.5.2
- Dart SDK >= 3.5.2

### 安装运行

```bash
# 获取依赖
flutter pub get

# 运行应用
flutter run
```

## Provider使用指南

### 1. 创建Provider

```dart
class ThemeProvider with ChangeNotifier {
  AppTheme _currentTheme = AppTheme.system;
  
  AppTheme get currentTheme => _currentTheme;
  
  void setTheme(AppTheme theme) {
    _currentTheme = theme;
    notifyListeners(); // 通知监听者更新
  }
}
```

### 2. 注册Provider

```dart
// 在 di/injector.dart 中注册
injector.registerFactory(() => ThemeProvider(injector<SharedPreferencesDb>()));

// 在 main.dart 中添加到MultiProvider
MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: injector<ThemeProvider>()),
  ],
  child: const MyApp(),
)
```

### 3. 使用Provider

```dart
// 方式1: Consumer监听变化
Consumer<ThemeProvider>(
  builder: (context, provider, child) {
    return Text(provider.currentTheme.displayName);
  },
)

// 方式2: context.read调用方法
context.read<ThemeProvider>().setTheme(AppTheme.dark);

// 方式3: context.watch获取值
final theme = context.watch<ThemeProvider>().currentTheme;

// 方式4: Provider.of
final provider = Provider.of<ThemeProvider>(context, listen: false);
```

### 4. 与MaterialApp集成

```dart
MaterialApp.router(
  themeMode: context.watch<ThemeProvider>().themeMode,
  theme: ThemeData.light(),
  darkTheme: ThemeData.dark(),
  locale: context.watch<LocaleProvider>().locale,
)
```

## 项目特色

### 事件驱动架构

MQTT模块采用事件驱动架构实现解耦：

```mermaid
graph LR
    A[MqttServerClientService] -->|发布事件| B[EventBus]
    B -->|订阅事件| C[MqttStateManager]
    C -->|更新状态| D[MqttState]
```

### 依赖注入

使用GetIt进行依赖注入，方便测试和解耦：

```dart
// 注册
injector.registerFactory(() => CounterProvider());
injector.registerLazySingleton(() => MqttState());

// 获取
final counter = injector<CounterProvider>();
```

### 持久化存储

支持多种存储方式：

- **SharedPreferences**: 通用键值存储
- **MMKV**: 高性能键值存储

```dart
class CounterProvider with ChangeNotifier {
  final KeyValueDb _db = injector<SharedPreferencesDb>();
  
  int get count => _db.get('count', 0);
  
  void increment() {
    _db.put('count', count + 1);
    notifyListeners();
  }
}
```

## 目录结构说明

```
lib/features/theme/
├── models/
│   └── app_theme.dart       # 主题枚举模型
├── view/
│   └── theme_page.dart      # 主题设置页面
└── theme_provider.dart      # 主题状态管理
```

每个功能模块遵循类似的结构：
- `models/`: 数据模型
- `view/`: UI页面
- `xxx_provider.dart`: 状态管理

## 学习路径

1. **基础**: 从计数器示例开始，理解ChangeNotifier和Consumer
2. **进阶**: 学习主题切换，了解与MaterialApp的集成
3. **扩展**: 多语言示例，掌握国际化基础
4. **复杂**: 应用设置，学习复杂对象的状态管理

## 常见问题

### Q: Provider和Bloc有什么区别？

Provider更轻量，适合简单状态管理；Bloc更适合复杂业务逻辑和大型项目。

### Q: 什么时候使用notifyListeners？

当状态发生变化需要通知UI更新时调用。注意不要在build方法中调用。

### Q: Consumer和Provider.of有什么区别？

Consumer会自动处理context，并且可以精确控制重建范围；Provider.of更灵活但需要手动管理。

## 许可证

MIT License
