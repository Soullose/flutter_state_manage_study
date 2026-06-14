import 'package:equatable/equatable.dart';

/// 认证模块的业务实体
///
/// Domain 层使用的纯 Dart 对象，不依赖任何框架或数据层
class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, name, avatarUrl, createdAt];
}
