/// 用户模型
class User {
  final String username;
  final String? email;
  final String? avatar;

  const User({required this.username, this.email, this.avatar});

  /// 未认证用户（仅用于演示）
  static const User unauthenticated = User(
    username: '',
    email: null,
    avatar: null,
  );

  /// 从 JSON 创建用户
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String? ?? '',
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {'username': username, 'email': email, 'avatar': avatar};
  }

  /// 复制并修改
  User copyWith({String? username, String? email, String? avatar}) {
    return User(
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
    );
  }

  @override
  String toString() {
    return 'User(username: $username, email: $email, avatar: $avatar)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.username == username &&
        other.email == email &&
        other.avatar == avatar;
  }

  @override
  int get hashCode => Object.hash(username, email, avatar);
}
