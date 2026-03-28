/// 主题类型枚举
enum ThemeType {
  /// 预置主题
  predefined,

  /// 自定义图片主题
  custom,
}

/// 主题配置模型
///
/// 用于存储用户选择的主题配置信息
class ThemeConfig {
  /// 主题类型
  final ThemeType type;

  /// 预置主题的key（当type为predefined时使用）
  final String? predefinedSchemeKey;

  /// 自定义图片路径或URL（当type为custom时使用）
  final String? customImageSource;

  /// 是否为网络图片
  final bool isNetworkImage;

  const ThemeConfig._({
    required this.type,
    this.predefinedSchemeKey,
    this.customImageSource,
    this.isNetworkImage = false,
  });

  /// 创建预置主题配置
  const ThemeConfig.predefined(String schemeKey)
    : type = ThemeType.predefined,
      predefinedSchemeKey = schemeKey,
      customImageSource = null,
      isNetworkImage = false;

  /// 创建自定义图片主题配置
  const ThemeConfig.custom(String imageSource, {this.isNetworkImage = false})
    : type = ThemeType.custom,
      predefinedSchemeKey = null,
      customImageSource = imageSource;

  /// 默认主题配置
  static const ThemeConfig defaultTheme = ThemeConfig.predefined('blue');

  /// 从JSON创建ThemeConfig
  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    final typeIndex = json['type'] as int? ?? 0;
    final type = ThemeType.values[typeIndex];

    if (type == ThemeType.predefined) {
      return ThemeConfig.predefined(
        json['predefinedSchemeKey'] as String? ?? 'blue',
      );
    } else {
      return ThemeConfig.custom(
        json['customImageSource'] as String? ?? '',
        isNetworkImage: json['isNetworkImage'] as bool? ?? false,
      );
    }
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'predefinedSchemeKey': predefinedSchemeKey,
      'customImageSource': customImageSource,
      'isNetworkImage': isNetworkImage,
    };
  }

  /// 复制并修改
  ThemeConfig copyWith({
    ThemeType? type,
    String? predefinedSchemeKey,
    String? customImageSource,
    bool? isNetworkImage,
  }) {
    return ThemeConfig._(
      type: type ?? this.type,
      predefinedSchemeKey: predefinedSchemeKey ?? this.predefinedSchemeKey,
      customImageSource: customImageSource ?? this.customImageSource,
      isNetworkImage: isNetworkImage ?? this.isNetworkImage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ThemeConfig &&
        other.type == type &&
        other.predefinedSchemeKey == predefinedSchemeKey &&
        other.customImageSource == customImageSource &&
        other.isNetworkImage == isNetworkImage;
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      predefinedSchemeKey,
      customImageSource,
      isNetworkImage,
    );
  }

  @override
  String toString() {
    if (type == ThemeType.predefined) {
      return 'ThemeConfig.predefined($predefinedSchemeKey)';
    } else {
      return 'ThemeConfig.custom($customImageSource, isNetworkImage: $isNetworkImage)';
    }
  }
}
