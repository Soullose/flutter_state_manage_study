import 'package:material_ui/material_ui.dart';
import 'package:provider_mode/core/store/key_value_db.dart';
import 'package:provider_mode/features/theme/models/app_theme.dart';

/// 主题状态管理Provider
///
/// 负责管理应用的主题状态，支持亮色、暗色和跟随系统三种模式
/// 状态会持久化存储，应用重启后保持用户选择
class ThemeProvider with ChangeNotifier {
  final KeyValueDb _db;

  /// 存储键名
  static const String _storageKey = 'app_theme';

  /// 当前主题
  AppTheme _currentTheme = AppTheme.system;

  ThemeProvider(this._db) {
    _loadTheme();
  }

  /// 获取当前主题
  AppTheme get currentTheme => _currentTheme;

  /// 获取Flutter的ThemeMode
  ThemeMode get themeMode => _currentTheme.toThemeMode();

  /// 判断是否是暗色模式
  bool get isDarkMode => _currentTheme == AppTheme.dark;

  /// 从存储中加载主题设置
  void _loadTheme() {
    final themeIndex = _db.get(_storageKey, AppTheme.system.index);
    _currentTheme = AppTheme.fromIndex(themeIndex);
  }

  /// 设置主题
  ///
  /// [theme] 要设置的主题模式
  void setTheme(AppTheme theme) {
    if (_currentTheme == theme) return;

    _currentTheme = theme;
    _db.put(_storageKey, theme.index);
    notifyListeners();
  }

  /// 切换亮色/暗色主题
  void toggleTheme() {
    if (_currentTheme == AppTheme.light) {
      setTheme(AppTheme.dark);
    } else {
      setTheme(AppTheme.light);
    }
  }

  /// 设置为亮色主题
  void setLightTheme() => setTheme(AppTheme.light);

  /// 设置为暗色主题
  void setDarkTheme() => setTheme(AppTheme.dark);

  /// 设置为跟随系统
  void setSystemTheme() => setTheme(AppTheme.system);
}
