import 'dart:io';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_color_extractor.g.dart';

/// 图片颜色提取服务
///
/// 使用 Flutter 原生的 ColorScheme.fromImageProvider 方法
/// 从图片中提取颜色并生成 Material 3 配色方案
class ImageColorExtractor {
  /// 从图片提供者生成 ColorScheme
  ///
  /// [provider] - 图片提供者
  /// [brightness] - 亮度模式（亮色/暗色）
  /// [variant] - 动态配色变体
  Future<ColorScheme> extractFromImageProvider(
    ImageProvider provider, {
    Brightness brightness = Brightness.light,
    DynamicSchemeVariant variant = DynamicSchemeVariant.tonalSpot,
  }) async {
    return await ColorScheme.fromImageProvider(
      provider: provider,
      brightness: brightness,
      dynamicSchemeVariant: variant,
    );
  }

  /// 从本地文件生成 ColorScheme
  ///
  /// [filePath] - 本地文件路径
  /// [brightness] - 亮度模式
  Future<ColorScheme> extractFromLocalFile(
    String filePath, {
    Brightness brightness = Brightness.light,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('文件不存在: $filePath');
    }

    final bytes = await file.readAsBytes();
    return extractFromImageProvider(MemoryImage(bytes), brightness: brightness);
  }

  /// 从网络图片生成 ColorScheme
  ///
  /// [url] - 网络图片URL
  /// [brightness] - 亮度模式
  Future<ColorScheme> extractFromNetworkUrl(
    String url, {
    Brightness brightness = Brightness.light,
  }) async {
    return extractFromImageProvider(NetworkImage(url), brightness: brightness);
  }

  /// 同时生成亮色和暗色 ColorScheme
  ///
  /// [provider] - 图片提供者
  /// 返回一个包含亮色和暗色 ColorScheme 的记录
  Future<({ColorScheme light, ColorScheme dark})> extractBothSchemes(
    ImageProvider provider,
  ) async {
    final light = await extractFromImageProvider(
      provider,
      brightness: Brightness.light,
    );
    final dark = await extractFromImageProvider(
      provider,
      brightness: Brightness.dark,
    );
    return (light: light, dark: dark);
  }

  /// 从本地文件同时生成亮色和暗色 ColorScheme
  Future<({ColorScheme light, ColorScheme dark})> extractBothSchemesFromFile(
    String filePath,
  ) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('文件不存在: $filePath');
    }

    final bytes = await file.readAsBytes();
    return extractBothSchemes(MemoryImage(bytes));
  }

  /// 从网络URL同时生成亮色和暗色 ColorScheme
  Future<({ColorScheme light, ColorScheme dark})> extractBothSchemesFromUrl(
    String url,
  ) async {
    return extractBothSchemes(NetworkImage(url));
  }
}

/// 图片颜色提取服务 Provider
@riverpod
ImageColorExtractor imageColorExtractor(Ref ref) {
  return ImageColorExtractor();
}
