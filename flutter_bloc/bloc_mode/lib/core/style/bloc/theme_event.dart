part of 'theme_bloc.dart';

/// 主题事件基类
sealed class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

/// 切换主题事件（亮/暗切换）
class ThemeToggled extends ThemeEvent {
  const ThemeToggled();
}

/// 设置指定主题模式
class ThemeChangedTo extends ThemeEvent {
  final ThemeMode themeMode;

  const ThemeChangedTo(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}

/// 从存储加载主题设置
class ThemeLoadedFromStorage extends ThemeEvent {
  const ThemeLoadedFromStorage();
}
