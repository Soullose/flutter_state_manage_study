import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'light_theme_provider.g.dart';

@riverpod
ThemeData lightTheme(Ref ref) {
  return FlexThemeData.light(scheme: FlexScheme.bahamaBlue);
}
