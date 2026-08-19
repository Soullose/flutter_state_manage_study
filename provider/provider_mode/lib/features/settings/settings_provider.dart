import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:provider_mode/core/store/key_value_db.dart';
import 'package:provider_mode/features/settings/models/app_settings.dart';

/// 应用设置状态管理Provider
///
/// 负责管理应用的各种设置选项
/// 展示如何管理复杂对象的状态
class SettingsProvider with ChangeNotifier {
  final KeyValueDb _db;

  /// 存储键名
  static const String _storageKey = 'app_settings';

  /// 当前设置
  AppSettings _settings = const AppSettings();

  SettingsProvider(this._db) {
    _loadSettings();
  }

  /// 获取当前设置
  AppSettings get settings => _settings;

  /// 从存储中加载设置
  void _loadSettings() {
    final settingsJson = _db.get(_storageKey, '');
    if (settingsJson.isNotEmpty) {
      try {
        final map = json.decode(settingsJson) as Map<String, dynamic>;
        _settings = AppSettings.fromMap(map);
      } catch (e) {
        debugPrint('加载设置失败: $e');
        _settings = const AppSettings();
      }
    }
  }

  /// 保存设置到存储
  void _saveSettings() {
    final jsonStr = json.encode(_settings.toMap());
    _db.put(_storageKey, jsonStr);
  }

  /// 更新设置
  void updateSettings(AppSettings newSettings) {
    _settings = newSettings;
    _saveSettings();
    notifyListeners();
  }

  /// 切换通知开关
  void toggleNotifications() {
    _settings = _settings.copyWith(
      notificationsEnabled: !_settings.notificationsEnabled,
    );
    _saveSettings();
    notifyListeners();
  }

  /// 切换声音开关
  void toggleSound() {
    _settings = _settings.copyWith(
      soundEnabled: !_settings.soundEnabled,
    );
    _saveSettings();
    notifyListeners();
  }

  /// 切换振动开关
  void toggleVibration() {
    _settings = _settings.copyWith(
      vibrationEnabled: !_settings.vibrationEnabled,
    );
    _saveSettings();
    notifyListeners();
  }

  /// 切换自动更新检查开关
  void toggleAutoUpdateCheck() {
    _settings = _settings.copyWith(
      autoUpdateCheck: !_settings.autoUpdateCheck,
    );
    _saveSettings();
    notifyListeners();
  }

  /// 切换数据统计开关
  void toggleAnalytics() {
    _settings = _settings.copyWith(
      analyticsEnabled: !_settings.analyticsEnabled,
    );
    _saveSettings();
    notifyListeners();
  }

  /// 清理缓存
  Future<void> clearCache() async {
    // 模拟清理缓存操作
    await Future.delayed(const Duration(seconds: 1));
    _settings = _settings.copyWith(cacheSizeMB: 0);
    _saveSettings();
    notifyListeners();
  }

  /// 计算缓存大小（模拟）
  Future<void> calculateCacheSize() async {
    // 模拟计算缓存大小
    await Future.delayed(const Duration(milliseconds: 500));
    _settings = _settings.copyWith(cacheSizeMB: 128); // 模拟128MB缓存
    notifyListeners();
  }

  /// 重置所有设置为默认值
  void resetToDefaults() {
    _settings = const AppSettings();
    _saveSettings();
    notifyListeners();
  }
}
