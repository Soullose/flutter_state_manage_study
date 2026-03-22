import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// 预置主题配置
///
/// 定义一个预置主题的所有信息，包括名称、描述、颜色方案等
class PredefinedTheme {
  /// 主题唯一标识key
  final String key;

  /// 主题名称
  final String name;

  /// 主题描述
  final String description;

  /// FlexColorScheme 的颜色方案
  final FlexScheme scheme;

  /// 主题主色调
  final Color primaryColor;

  /// 主题次要色调
  final Color? secondaryColor;

  const PredefinedTheme({
    required this.key,
    required this.name,
    required this.description,
    required this.scheme,
    required this.primaryColor,
    this.secondaryColor,
  });

  /// 获取亮色主题数据
  ThemeData get lightTheme =>
      FlexThemeData.light(scheme: scheme, useMaterial3: true);

  /// 获取暗色主题数据
  ThemeData get darkTheme =>
      FlexThemeData.dark(scheme: scheme, useMaterial3: true);
}

/// 精选预置主题列表
///
/// 包含6种精选的颜色主题供用户选择
const List<PredefinedTheme> kPredefinedThemes = [
  PredefinedTheme(
    key: 'blue',
    name: '海洋蓝',
    description: '经典蓝色主题',
    scheme: FlexScheme.blue,
    primaryColor: Color(0xFF1976D2),
  ),
  PredefinedTheme(
    key: 'indigo',
    name: '靛青',
    description: '深邃靛青主题',
    scheme: FlexScheme.indigo,
    primaryColor: Color(0xFF3F51B5),
  ),
  PredefinedTheme(
    key: 'tealM3',
    name: '青碧',
    description: '清新青碧主题',
    scheme: FlexScheme.tealM3,
    primaryColor: Color(0xFF009688),
  ),
  PredefinedTheme(
    key: 'green',
    name: '翠绿',
    description: '自然翠绿主题',
    scheme: FlexScheme.green,
    primaryColor: Color(0xFF4CAF50),
  ),
  PredefinedTheme(
    key: 'purpleM3',
    name: '典雅紫',
    description: '优雅紫色主题',
    scheme: FlexScheme.purpleM3,
    primaryColor: Color(0xFF9C27B0),
  ),
  PredefinedTheme(
    key: 'sakura',
    name: '樱花粉',
    description: '温柔粉色主题',
    scheme: FlexScheme.sakura,
    primaryColor: Color(0xFFEC407A),
  ),
];

/// 根据key获取预置主题
PredefinedTheme? getPredefinedThemeByKey(String key) {
  try {
    return kPredefinedThemes.firstWhere((theme) => theme.key == key);
  } catch (_) {
    return null;
  }
}

/// 默认预置主题
PredefinedTheme get defaultPredefinedTheme => kPredefinedThemes.first;
