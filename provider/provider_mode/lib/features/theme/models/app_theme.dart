import 'package:material_ui/material_ui.dart';

/// 应用主题枚举
enum AppTheme {
  /// 亮色主题
  light,

  /// 暗色主题
  dark,

  /// 跟随系统
  system;

  /// 转换为Flutter的ThemeMode
  ThemeMode toThemeMode() {
    switch (this) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
        return ThemeMode.system;
    }
  }

  /// 获取主题显示名称
  String get displayName {
    switch (this) {
      case AppTheme.light:
        return '亮色主题';
      case AppTheme.dark:
        return '暗色主题';
      case AppTheme.system:
        return '跟随系统';
    }
  }

  /// 获取主题图标
  IconData get icon {
    switch (this) {
      case AppTheme.light:
        return Icons.light_mode;
      case AppTheme.dark:
        return Icons.dark_mode;
      case AppTheme.system:
        return Icons.brightness_auto;
    }
  }

  /// 从索引创建AppTheme
  static AppTheme fromIndex(int index) {
    if (index < 0 || index >= AppTheme.values.length) {
      return AppTheme.system;
    }
    return AppTheme.values[index];
  }
}
