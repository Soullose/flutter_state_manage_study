import 'package:bloc/bloc.dart';
import 'package:bloc_mode/core/storage/shared_preferences_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'locale_event.dart';
part 'locale_state.dart';

/// 多语言Bloc - 管理应用语言状态
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final SharedPreferencesUtils _prefs;
  static const String _localeKey = 'locale';

  LocaleBloc({required SharedPreferencesUtils prefs})
    : _prefs = prefs,
      super(const LocaleState()) {
    on<LocaleChanged>(_onChange);
    on<LocaleToggled>(_onToggle);
    on<LocaleLoadedFromStorage>(_onLoadFromStorage);
  }

  /// 切换语言（中/英切换）
  Future<void> _onToggle(LocaleToggled event, Emitter<LocaleState> emit) async {
    final Locale newLocale;
    if (state.isChinese) {
      newLocale = const Locale('en', 'US');
    } else {
      newLocale = const Locale('zh', 'CN');
    }
    await _saveLocale(newLocale);
    emit(state.copyWith(locale: newLocale));
  }

  /// 设置指定语言
  Future<void> _onChange(LocaleChanged event, Emitter<LocaleState> emit) async {
    await _saveLocale(event.locale);
    emit(state.copyWith(locale: event.locale));
  }

  /// 从存储加载语言设置
  Future<void> _onLoadFromStorage(
    LocaleLoadedFromStorage event,
    Emitter<LocaleState> emit,
  ) async {
    final savedLocale = await _loadLocale();
    emit(state.copyWith(locale: savedLocale));
  }

  /// 保存语言设置到本地存储
  Future<void> _saveLocale(Locale locale) async {
    await _prefs.setString(
      _localeKey,
      '${locale.languageCode}_${locale.countryCode}',
    );
  }

  /// 从本地存储加载语言设置
  Locale _loadLocale() {
    final localeStr = _prefs.getString(_localeKey);
    switch (localeStr) {
      case 'zh_CN':
        return const Locale('zh', 'CN');
      case 'en_US':
        return const Locale('en', 'US');
      default:
        return const Locale('zh', 'CN'); // 默认中文
    }
  }
}
