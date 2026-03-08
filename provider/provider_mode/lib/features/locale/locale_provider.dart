import 'package:flutter/material.dart';
import 'package:provider_mode/core/store/key_value_db.dart';
import 'package:provider_mode/features/locale/models/app_locale.dart';

/// 语言状态管理Provider
///
/// 负责管理应用的语言设置，支持中文、英文和跟随系统三种模式
/// 状态会持久化存储，应用重启后保持用户选择
class LocaleProvider with ChangeNotifier {
  final KeyValueDb _db;

  /// 存储键名
  static const String _storageKey = 'app_locale';

  /// 当前语言设置
  AppLocale _currentLocale = AppLocale.system;

  LocaleProvider(this._db) {
    _loadLocale();
  }

  /// 获取当前语言设置
  AppLocale get currentLocale => _currentLocale;

  /// 获取Flutter的Locale
  /// 返回null表示跟随系统
  Locale? get locale => _currentLocale.toLocale();

  /// 获取支持的语言列表
  List<Locale> get supportedLocales => const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ];

  /// 从存储中加载语言设置
  void _loadLocale() {
    final localeIndex = _db.get(_storageKey, AppLocale.system.index);
    _currentLocale = AppLocale.fromIndex(localeIndex);
  }

  /// 设置语言
  ///
  /// [appLocale] 要设置的语言
  void setLocale(AppLocale appLocale) {
    if (_currentLocale == appLocale) return;

    _currentLocale = appLocale;
    _db.put(_storageKey, appLocale.index);
    notifyListeners();
  }

  /// 设置为中文
  void setChinese() => setLocale(AppLocale.zh);

  /// 设置为英文
  void setEnglish() => setLocale(AppLocale.en);

  /// 设置为跟随系统
  void setSystemLocale() => setLocale(AppLocale.system);

  /// 根据Locale更新当前语言（用于系统语言变化时）
  void updateFromLocale(Locale? locale) {
    if (_currentLocale == AppLocale.system) {
      // 只有在跟随系统模式下才需要通知UI更新
      notifyListeners();
    }
  }
}
