import 'package:equatable/equatable.dart';
import 'package:provider_mode/features/reader/domain/entities/reader_source_type.dart';

sealed class ReaderSource extends Equatable {
  const ReaderSource();

  /// 源类型标识（用于错误提示与强制路由）
  ReaderSourceType get type;

  /// 扩展名（小写、无点；URL 源从路径解析；Content 源为空）
  String? get extension => null;
}

/// 本地文件路径源
class FilePathSource extends ReaderSource {
  final String path;
  const FilePathSource(this.path);

  @override
  ReaderSourceType get type => ReaderSourceType.localFile;

  @override
  String? get extension {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) return null;
    return path.substring(dot + 1).toLowerCase();
  }

  @override
  List<Object?> get props => [path];
}

/// 在线 URL 源
class UrlSource extends ReaderSource {
  final String url;
  const UrlSource(this.url);

  @override
  ReaderSourceType get type => ReaderSourceType.onlineUrl;

  @override
  String? get extension {
    final uri = Uri.tryParse(url);
    final seg = uri?.pathSegments;
    if (seg == null || seg.isEmpty) return null;
    final last = seg.last;
    final dot = last.lastIndexOf('.');
    if (dot < 0) return null;
    return last.substring(dot + 1).toLowerCase();
  }

  @override
  List<Object?> get props => [url];
}

/// 直接内容源（用于测试：注入文本，免 IO）
class ContentSource extends ReaderSource {
  final String content;
  final ReaderSourceType explicitType;
  const ContentSource(this.content,
      {this.explicitType = ReaderSourceType.localFile});

  @override
  ReaderSourceType get type => explicitType;

  @override
  List<Object?> get props => [content, explicitType];
}

/// Asset 源（资源文件，后续扩展）
class AssetSource extends ReaderSource {
  final String assetPath;
  const AssetSource(this.assetPath);

  @override
  ReaderSourceType get type => ReaderSourceType.asset;

  @override
  String? get extension {
    final dot = assetPath.lastIndexOf('.');
    if (dot < 0) return null;
    return assetPath.substring(dot + 1).toLowerCase();
  }

  @override
  List<Object?> get props => [assetPath];
}
