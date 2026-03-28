# Flutter 状态管理学习项目

本项目是一个用于学习和比较 Flutter 不同状态管理方案的示例集合。包含四个独立的 Flutter 项目，分别使用 BLoC、Provider、Riverpod 和 GetX 作为状态管理库。

## 项目概览

| 项目 | 路径 | 状态管理库 | 主要特点 |
|------|------|------------|----------|
| BLoC | [`flutter_bloc/bloc_mode/`](flutter_bloc/bloc_mode/) | flutter_bloc 9.1.1 | Clean Architecture，主题切换，多语言，认证，MQTT，计数器，计时器 |
| Provider | [`provider/provider_mode/`](provider/provider_mode/) | provider 6.1.5+1 | Clean Architecture，主题切换，多语言，设置，MQTT，日志记录 |
| Riverpod | [`riverpod/riverpod_mode/`](riverpod/riverpod_mode/) | flutter_riverpod 3.3.1 | 主题切换，TTS，错误日志，MQTT，个人资料页面 |
| GetX | [`getx/getx_mode/`](getx/getx_mode/) | get 5.0.0 | 模块化设计，欢迎页面，响应式 UI |

## 快速开始

每个项目都是独立的 Flutter 应用，可以单独运行：

```bash
cd flutter_bloc/bloc_mode
flutter pub get
flutter run
```

## 详细说明

### 1. BLoC 项目 (`flutter_bloc/bloc_mode/`)

**技术栈**:
- Flutter 3.41.x, Dart 3.8.0
- flutter_bloc 9.1.1, bloc 9.2.0
- go_router 17.1.0, auto_route 9.2.2
- get_it 9.2.1 (依赖注入)
- dio 5.9.2 (网络请求)
- shared_preferences 2.5.4 (本地存储)
- mqtt_client 10.11.1 (MQTT 客户端)

**功能特性**:
- 主题切换（浅色/深色/系统跟随）
- 多语言支持（中文/英文）
- 认证系统（登录/登出）
- 路由守卫（基于认证状态）
- 计数器示例（Bloc 和 Cubit 两种实现）
- 计时器示例
- MQTT 客户端演示
- 设置页面（主题、语言、登出）

**项目结构**:
```
lib/
├── core/          # 核心基础设施（路由、存储、错误处理）
├── features/      # 功能模块（auth, counter, timer, setting）
└── di/            # 依赖注入配置
```

### 2. Provider 项目 (`provider/provider_mode/`)

**技术栈**:
- Flutter 3.41.x, Dart 3.5.2
- provider 6.1.5+1
- go_router 17.1.0
- get_it 9.1.1 (依赖注入)
- dio 5.9.2 (网络请求)
- shared_preferences 2.3.4, mmkv 2.4.0 (本地存储)
- mqtt_client 10.11.1 (MQTT 客户端)

**功能特性**:
- 计数器示例（ChangeNotifier）
- 主题切换（亮色/暗色/系统跟随）
- 多语言支持（中文/英文）
- 应用设置（通知、声音、振动开关）
- 认证模块（Clean Architecture）
- MQTT 事件驱动架构
- 日志记录与错误处理

**项目结构**:
```
lib/
├── core/          # 核心基础设施（路由、存储、MQTT、事件总线）
├── features/      # 功能模块（counter, theme, locale, settings, auth）
├── di/            # 依赖注入
└── l10n/          # 国际化
```

### 3. Riverpod 项目 (`riverpod/riverpod_mode/`)

**技术栈**:
- Flutter 3.22.0+, Dart 3.8.0
- flutter_riverpod 3.3.1, riverpod_annotation 4.0.2
- go_router 15.1.1, auto_route 9.2.2
- get_it 9.2.1 (依赖注入)
- dio 5.9.0 (网络请求)
- shared_preferences 2.5.5, mmkv 2.4.0 (本地存储)
- 离线 TTS（文本转语音）引擎

**功能特性**:
- 主题切换（动态配色方案）
- 离线 TTS（Sherpa ONNX 引擎）
- 错误日志收集与展示
- MQTT 客户端
- 个人资料页面（许可证、隐私政策）
- 计数器示例
- 计时器示例

**项目结构**:
```
lib/
├── common/        # 通用工具（网络、存储、主题）
├── core/          # 核心基础设施（错误处理、MQTT）
├── features/      # 功能模块（counter, tts, error_log, profile）
├── generated/     # 生成的国际化代码
├── route/         # 路由配置
└── utils/         # 工具类
```

### 4. GetX 项目 (`getx/getx_mode/`)

**技术栈**:
- Flutter 3.7.2, Dart 3.7.2
- get 5.0.0-release-candidate-9.3.2
- dio 5.8.0+1 (网络请求)
- animations 2.0.11 (动画)
- flutter_screenutil 5.9.3 (屏幕适配)

**功能特性**:
- 模块化架构（Welcome 模块）
- 响应式 UI（使用 GetX 状态管理）
- 路由管理（GetX 内置路由）
- 主题定制（自定义主题颜色）

**项目结构**:
```
lib/
├── modules/       # 功能模块（welcome）
├── router/        # 路由配置
└── style/         # 样式主题
```

## 技术栈对比

| 特性 | BLoC | Provider | Riverpod | GetX |
|------|------|----------|----------|------|
| 状态管理方式 | 事件驱动 | ChangeNotifier | Provider/Notifier | 响应式 |
| 学习曲线 | 中等 | 简单 | 中等 | 简单 |
| 代码生成 | 可选（bloc_generator） | 无 | 需要（riverpod_generator） | 无 |
| 依赖注入 | 需要额外库（get_it） | 需要额外库（get_it） | 内置 | 内置 |
| 路由集成 | 需要 go_router/auto_route | 需要 go_router | 需要 go_router/auto_route | 内置 |
| 国际化支持 | 需要额外配置 | 需要额外配置 | 需要额外配置 | 需要额外配置 |
| 适合场景 | 大型复杂应用 | 中小型应用 | 大型复杂应用 | 快速原型 |

## 学习资源

- [Flutter Bloc 官方文档](https://bloclibrary.dev/)
- [Provider 官方文档](https://pub.dev/packages/provider)
- [Riverpod 官方文档](https://riverpod.dev/)
- [GetX 官方文档](https://pub.dev/packages/get)

## 许可证

本项目仅用于学习目的，代码遵循 MIT 许可证。