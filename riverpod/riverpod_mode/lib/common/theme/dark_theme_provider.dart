import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dark_theme_provider.g.dart';

@riverpod
ThemeData darkTheme(Ref ref) {
  return FlexThemeData.dark(scheme: FlexScheme.bahamaBlue);
}
