import 'package:material_ui/material_ui.dart';

/// 应用语言枚举
enum AppLocale {
  /// 中文
  zh,

  /// 英文
  en,

  /// 跟随系统
  system;

  /// 转换为Flutter的Locale
  Locale? toLocale() {
    switch (this) {
      case AppLocale.zh:
        return const Locale('zh', 'CN');
      case AppLocale.en:
        return const Locale('en', 'US');
      case AppLocale.system:
        return null; // null表示跟随系统
    }
  }

  /// 获取语言显示名称
  String get displayName {
    switch (this) {
      case AppLocale.zh:
        return '简体中文';
      case AppLocale.en:
        return 'English';
      case AppLocale.system:
        return '跟随系统';
    }
  }

  /// 获取语言的本地名称（用于展示）
  String get nativeName {
    switch (this) {
      case AppLocale.zh:
        return '中文';
      case AppLocale.en:
        return 'English';
      case AppLocale.system:
        return '系统';
    }
  }

  /// 获取语言图标（国旗emoji替代）
  String get flag {
    switch (this) {
      case AppLocale.zh:
        return '🇨🇳';
      case AppLocale.en:
        return '🇺🇸';
      case AppLocale.system:
        return '🌐';
    }
  }

  /// 从索引创建AppLocale
  static AppLocale fromIndex(int index) {
    if (index < 0 || index >= AppLocale.values.length) {
      return AppLocale.system;
    }
    return AppLocale.values[index];
  }

  /// 从Locale创建AppLocale
  static AppLocale fromLocale(Locale? locale) {
    if (locale == null) return AppLocale.system;
    switch (locale.languageCode) {
      case 'zh':
        return AppLocale.zh;
      case 'en':
        return AppLocale.en;
      default:
        return AppLocale.system;
    }
  }
}
