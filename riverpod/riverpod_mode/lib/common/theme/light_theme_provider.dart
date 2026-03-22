import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'theme_config_provider.dart';

part 'light_theme_provider.g.dart';

/// 亮色主题 Provider
///
/// 使用 theme_config_provider 中的主题配置
@riverpod
ThemeData lightTheme(Ref ref) {
  return ref.watch(lightThemeProvider);
}
