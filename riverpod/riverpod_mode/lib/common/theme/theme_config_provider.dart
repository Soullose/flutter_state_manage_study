import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/theme/services/image_color_extractor.dart';
import 'predefined_themes.dart';
import 'theme_config.dart';
import 'theme_persistence.dart';

part 'theme_config_provider.g.dart';

/// 主题配置状态管理
///
/// 管理用户选择的主题配置，包括预置主题和自定义图片主题
@riverpod
class ThemeConfigNotifier extends _$ThemeConfigNotifier {
  late ThemePersistenceService _persistenceService;

  @override
  ThemeConfig build() {
    _persistenceService = ref.watch(themePersistenceProvider);

    // 加载保存的主题配置
    final savedConfig = _persistenceService.loadThemeConfig();
    return savedConfig ?? ThemeConfig.defaultTheme;
  }

  /// 切换到预置主题
  Future<void> setPredefinedTheme(String schemeKey) async {
    final config = ThemeConfig.predefined(schemeKey);
    await _persistenceService.saveThemeConfig(config);
    state = config;
  }

  /// 从本地图片创建自定义主题
  Future<void> setCustomThemeFromLocalImage(String imagePath) async {
    final config = ThemeConfig.custom(imagePath, isNetworkImage: false);
    await _persistenceService.saveThemeConfig(config);
    state = config;
  }

  /// 从网络图片创建自定义主题
  Future<void> setCustomThemeFromNetworkImage(String imageUrl) async {
    final config = ThemeConfig.custom(imageUrl, isNetworkImage: true);
    await _persistenceService.saveThemeConfig(config);
    state = config;
  }

  /// 重置为默认主题
  Future<void> resetToDefault() async {
    await _persistenceService.saveThemeConfig(ThemeConfig.defaultTheme);
    state = ThemeConfig.defaultTheme;
  }
}

/// 自定义图片主题的 ColorScheme 状态
///
/// 用于异步加载图片并生成 ColorScheme
@riverpod
class CustomColorScheme extends _$CustomColorScheme {
  @override
  Future<({ColorScheme light, ColorScheme dark})?> build() async {
    final config = ref.watch(themeConfigProvider);

    if (config.type != ThemeType.custom || config.customImageSource == null) {
      return null;
    }

    final extractor = ref.read(imageColorExtractorProvider);

    try {
      if (config.isNetworkImage) {
        return await extractor.extractBothSchemesFromUrl(
          config.customImageSource!,
        );
      } else {
        return await extractor.extractBothSchemesFromFile(
          config.customImageSource!,
        );
      }
    } catch (e) {
      // 加载失败返回null，将使用默认主题
      return null;
    }
  }

  /// 重新加载颜色方案
  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await build());
  }
}

/// 亮色主题 Provider
@riverpod
ThemeData lightTheme(Ref ref) {
  final config = ref.watch(themeConfigProvider);

  if (config.type == ThemeType.predefined) {
    final theme = getPredefinedThemeByKey(config.predefinedSchemeKey ?? 'blue');
    if (theme != null) {
      return theme.lightTheme;
    }
  }

  // 自定义主题 - 尝试加载图片颜色
  final customScheme = ref.watch(customColorSchemeProvider);
  if (customScheme.hasValue && customScheme.value != null) {
    final colorScheme = customScheme.value!.light;
    return _buildThemeFromColorScheme(colorScheme, Brightness.light);
  }

  // 回退到默认主题
  return defaultPredefinedTheme.lightTheme;
}

/// 暗色主题 Provider
@riverpod
ThemeData darkTheme(Ref ref) {
  final config = ref.watch(themeConfigProvider);

  if (config.type == ThemeType.predefined) {
    final theme = getPredefinedThemeByKey(config.predefinedSchemeKey ?? 'blue');
    if (theme != null) {
      return theme.darkTheme;
    }
  }

  // 自定义主题 - 尝试加载图片颜色
  final customScheme = ref.watch(customColorSchemeProvider);
  if (customScheme.hasValue && customScheme.value != null) {
    final colorScheme = customScheme.value!.dark;
    return _buildThemeFromColorScheme(colorScheme, Brightness.dark);
  }

  // 回退到默认主题
  return defaultPredefinedTheme.darkTheme;
}

/// 从 ColorScheme 构建 ThemeData
ThemeData _buildThemeFromColorScheme(
  ColorScheme colorScheme,
  Brightness brightness,
) {
  return ThemeData(colorScheme: colorScheme, useMaterial3: true);
}
