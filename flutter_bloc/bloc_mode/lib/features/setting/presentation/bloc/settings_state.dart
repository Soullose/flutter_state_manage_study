part of 'settings_bloc.dart';

/// 设置状态
class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;
  final bool notificationsEnabled;
  final String? serverIp;
  final String? serverPort;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('zh', 'CN'),
    this.notificationsEnabled = true,
    this.serverIp,
    this.serverPort,
  });

  /// 创建初始状态
  const SettingsState.initial({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('zh', 'CN'),
    this.notificationsEnabled = true,
    this.serverIp,
    this.serverPort,
  });

  /// 复制并修改
  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? notificationsEnabled,
    String? serverIp,
    String? serverPort,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      serverIp: serverIp ?? this.serverIp,
      serverPort: serverPort ?? this.serverPort,
    );
  }

  @override
  List<Object?> get props => [
    themeMode,
    locale,
    notificationsEnabled,
    serverIp,
    serverPort,
  ];
}
