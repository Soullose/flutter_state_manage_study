part of 'settings_bloc.dart';

/// 设置事件基类
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// 主题变更事件
class SettingsThemeChanged extends SettingsEvent {
  final ThemeMode themeMode;

  const SettingsThemeChanged(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

/// 语言变更事件
class SettingsLocaleChanged extends SettingsEvent {
  final Locale locale;

  const SettingsLocaleChanged(this.locale);

  @override
  List<Object?> get props => [locale];
}

/// 通知开关事件
class SettingsNotificationsToggled extends SettingsEvent {
  final bool enabled;

  const SettingsNotificationsToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// 服务器配置变更事件
class SettingsServerChanged extends SettingsEvent {
  final String? ip;
  final String? port;

  const SettingsServerChanged({this.ip, this.port});

  @override
  List<Object?> get props => [ip, port];
}
