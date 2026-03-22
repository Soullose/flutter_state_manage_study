import 'package:flutter/material.dart';

import '../../../common/theme/predefined_themes.dart';

/// 主题预览卡片
///
/// 用于在主题设置页面展示单个预置主题的预览效果
class ThemePreviewCard extends StatelessWidget {
  /// 预置主题配置
  final PredefinedTheme theme;

  /// 是否被选中
  final bool isSelected;

  /// 点击回调
  final VoidCallback onTap;

  const ThemePreviewCard({
    super.key,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 主题颜色预览圆圈
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primaryColor,
                    theme.secondaryColor ?? theme.primaryColor.withOpacity(0.7),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 28,
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            // 主题名称
            Text(
              theme.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? theme.primaryColor : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            // 主题描述
            Text(
              theme.description,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// 自定义主题预览卡片
///
/// 用于展示从图片生成的自定义主题
class CustomThemePreviewCard extends StatelessWidget {
  /// 图片路径或URL
  final String? imageSource;

  /// 是否为网络图片
  final bool isNetworkImage;

  /// 是否被选中
  final bool isSelected;

  /// 点击回调
  final VoidCallback onTap;

  /// 删除回调（可选）
  final VoidCallback? onDelete;

  const CustomThemePreviewCard({
    super.key,
    this.imageSource,
    this.isNetworkImage = false,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: imageSource != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 图片缩略图
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: isNetworkImage
                              ? Image.network(
                                  imageSource!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 60,
                                    height: 60,
                                    color: colorScheme.primaryContainer,
                                    child: Icon(
                                      Icons.broken_image,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                )
                              : Image.asset(
                                  imageSource!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 60,
                                    height: 60,
                                    color: colorScheme.primaryContainer,
                                    child: Icon(
                                      Icons.broken_image,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '自定义主题',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 40,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '添加图片',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
            ),
            // 选中标记
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            // 删除按钮
            if (onDelete != null && imageSource != null)
              Positioned(
                top: 8,
                left: 8,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
