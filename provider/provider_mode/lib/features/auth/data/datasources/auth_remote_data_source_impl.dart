import 'package:provider_mode/features/auth/data/models/user_model.dart';

import 'auth_remote_data_source.dart';

/// Auth 远程数据源的 Mock 实现
///
/// 模拟网络请求延迟，用于学习和测试 Provider 状态管理
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  /// 模拟网络延迟（毫秒）
  final int mockDelayMs;

  /// Mock 用户数据库
  static const _mockUsers = <String, String>{
    'test@example.com': '123456',
    'admin@example.com': 'admin123',
  };

  AuthRemoteDataSourceImpl({this.mockDelayMs = 1500});

  @override
  Future<UserModel> login(String email, String password) async {
    // 模拟网络延迟
    await Future.delayed(Duration(milliseconds: mockDelayMs));

    // 验证邮箱格式
    if (!email.contains('@')) {
      throw ArgumentError('邮箱格式不正确');
    }

    // 验证密码长度
    if (password.length < 6) {
      throw ArgumentError('密码长度不能少于6位');
    }

    // 模拟用户验证
    if (!_mockUsers.containsKey(email)) {
      throw Exception('用户不存在');
    }

    if (_mockUsers[email] != password) {
      throw Exception('密码错误');
    }

    // 返回模拟的用户数据
    return UserModel(
      id: 'user_${email.hashCode}',
      email: email,
      name: email.split('@').first,
      avatarUrl: null,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> logout() async {
    // 模拟网络延迟
    await Future.delayed(Duration(milliseconds: mockDelayMs ~/ 2));
  }

  @override
  Future<UserModel> register(String email, String password) async {
    // 模拟网络延迟
    await Future.delayed(Duration(milliseconds: mockDelayMs));

    // 验证输入
    if (!email.contains('@')) {
      throw ArgumentError('邮箱格式不正确');
    }

    if (password.length < 6) {
      throw ArgumentError('密码长度不能少于6位');
    }

    if (_mockUsers.containsKey(email)) {
      throw Exception('该邮箱已被注册');
    }

    // 返回新用户数据
    return UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: email.split('@').first,
      avatarUrl: null,
      createdAt: DateTime.now(),
    );
  }
}
