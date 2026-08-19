import 'package:bloc/bloc.dart';
import 'package:bloc_mode/core/storage/mmkv_service.dart';
import 'package:equatable/equatable.dart';
import 'package:material_ui/material_ui.dart';

part 'theme_event.dart';
part 'theme_state.dart';

/// 主题Bloc - 管理应用主题状态
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final MmkvDb _mmkv;
  static const String _themeModeKey = 'theme_mode';

  ThemeBloc({required MmkvDb mmkv}) : _mmkv = mmkv, super(const ThemeState()) {
    on<ThemeToggled>(_onToggled);
    on<ThemeChangedTo>(_onChangeTo);
    on<ThemeLoadedFromStorage>(_onLoadFromStorage);
  }

  /// 切换主题（亮/暗切换）
  Future<void> _onToggled(ThemeToggled event, Emitter<ThemeState> emit) async {
    final ThemeMode newMode;
    switch (state.themeMode) {
      case ThemeMode.light:
        newMode = ThemeMode.dark;
      case ThemeMode.dark:
        newMode = ThemeMode.light;
      case ThemeMode.system:
        newMode = ThemeMode.light;
    }
    await _saveThemeMode(newMode);
    emit(state.copyWith(themeMode: newMode));
  }

  /// 设置指定主题模式
  Future<void> _onChangeTo(
    ThemeChangedTo event,
    Emitter<ThemeState> emit,
  ) async {
    await _saveThemeMode(event.themeMode);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  /// 从存储加载主题设置
  Future<void> _onLoadFromStorage(
    ThemeLoadedFromStorage event,
    Emitter<ThemeState> emit,
  ) async {
    final savedMode = await _loadThemeMode();
    emit(state.copyWith(themeMode: savedMode));
  }

  /// 保存主题模式到本地存储
  Future<void> _saveThemeMode(ThemeMode mode) async {
    await _mmkv.put(_themeModeKey, mode.name);
  }

  /// 从本地存储加载主题模式
  Future<ThemeMode> _loadThemeMode() async {
    final modeName = _mmkv.get<String>(_themeModeKey, '');
    switch (modeName) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
