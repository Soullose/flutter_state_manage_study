part of 'theme_bloc.dart';

/// 主题状态类
class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState({this.themeMode = ThemeMode.system});

  /// 是否为暗色主题
  bool get isDarkMode => themeMode == ThemeMode.dark;

  /// 是否为亮色主题
  bool get isLightMode => themeMode == ThemeMode.light;

  /// 是否跟随系统
  bool get isSystemMode => themeMode == ThemeMode.system;

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(themeMode: themeMode ?? this.themeMode);
  }

  @override
  List<Object> get props => [themeMode];

  @override
  String toString() => 'ThemeState(themeMode: $themeMode)';
}
