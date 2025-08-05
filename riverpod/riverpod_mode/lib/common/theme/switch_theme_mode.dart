import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'switch_theme_mode.g.dart';

@riverpod
class SwitchThemeMode extends _$SwitchThemeMode {
  @override
  ThemeMode build() {
    return ThemeMode.system;
  }
}

