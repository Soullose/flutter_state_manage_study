import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/mmkv/mmkv_service.dart';
import '../storage/mmkv/provider/mmkv_service_provider.dart';
import 'theme_config.dart';

part 'theme_persistence.g.dart';

/// 主题持久化服务
///
/// 负责将主题配置保存到本地存储，并在应用启动时恢复
class ThemePersistenceService {
  static const String _keyThemeConfig = 'theme_config';
  static const String _keyThemeMode = 'theme_mode';

  final MMKVService _mmkv;

  ThemePersistenceService(this._mmkv);

  /// 保存主题配置
  Future<void> saveThemeConfig(ThemeConfig config) async {
    final jsonString = jsonEncode(config.toJson());
    await _mmkv.put(_keyThemeConfig, jsonString);
  }

  /// 加载主题配置
  ThemeConfig? loadThemeConfig() {
    final jsonString = _mmkv.get<String>(_keyThemeConfig, '');
    if (jsonString.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return ThemeConfig.fromJson(json);
    } catch (e) {
      // 解析失败返回null
      return null;
    }
  }

  /// 清除主题配置
  Future<void> clearThemeConfig() async {
    await _mmkv.put(_keyThemeConfig, '');
  }

  /// 保存主题模式（明/暗/跟随系统）
  Future<void> saveThemeMode(ThemeMode mode) async {
    await _mmkv.put(_keyThemeMode, mode.index);
  }

  /// 加载主题模式
  ThemeMode loadThemeMode() {
    final index = _mmkv.get<int>(_keyThemeMode, -1);
    if (index < 0 || index >= ThemeMode.values.length) {
      return ThemeMode.system;
    }
    return ThemeMode.values[index];
  }

  /// 清除主题模式
  Future<void> clearThemeMode() async {
    await _mmkv.put(_keyThemeMode, -1);
  }
}

/// 主题持久化服务 Provider
@riverpod
ThemePersistenceService themePersistence(Ref ref) {
  final mmkvService = ref.watch(mmkvServiceProvider);
  return ThemePersistenceService(mmkvService);
}
