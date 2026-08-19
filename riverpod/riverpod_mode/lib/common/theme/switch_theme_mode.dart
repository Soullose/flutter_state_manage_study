import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'theme_persistence.dart';

part 'switch_theme_mode.g.dart';

@riverpod
class SwitchThemeMode extends _$SwitchThemeMode {
  late ThemePersistenceService _persistenceService;

  @override
  ThemeMode build() {
    _persistenceService = ref.watch(themePersistenceProvider);
    // 加载保存的主题模式
    return _persistenceService.loadThemeMode();
  }

  /// 切换主题模式
  void toggle() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setMode(newMode);
  }

  /// 设置主题模式
  void setMode(ThemeMode mode) {
    _persistenceService.saveThemeMode(mode);
    state = mode;
  }
}
