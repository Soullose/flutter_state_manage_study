import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dark_theme_provider.g.dart';

/// 暗色主题 Provider
///
/// 使用 theme_config_provider 中的主题配置
@riverpod
ThemeData darkTheme(Ref ref) {
  return ref.watch(darkThemeProvider);
}
