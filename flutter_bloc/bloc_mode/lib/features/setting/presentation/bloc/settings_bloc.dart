import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'settings_event.dart';
part 'settings_state.dart';

/// 设置 Bloc
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState.initial()) {
    on<SettingsThemeChanged>(_onThemeChanged);
    on<SettingsLocaleChanged>(_onLocaleChanged);
    on<SettingsNotificationsToggled>(_onNotificationsToggled);
    on<SettingsServerChanged>(_onServerChanged);
  }

  void _onThemeChanged(
    SettingsThemeChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(themeMode: event.themeMode));
  }

  void _onLocaleChanged(
    SettingsLocaleChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(locale: event.locale));
  }

  void _onNotificationsToggled(
    SettingsNotificationsToggled event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(notificationsEnabled: event.enabled));
  }

  void _onServerChanged(
    SettingsServerChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(serverIp: event.ip, serverPort: event.port));
  }
}
