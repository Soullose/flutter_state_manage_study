import 'package:bloc_mode/core/storage/mmkv_service.dart';
import 'package:bloc_mode/core/utils/app_logger.dart';
import 'package:bloc_mode/features/auth/models/user.dart';

/// 认证仓库接口
abstract class AuthRepository {
  /// 检查用户是否已登录
  Future<bool> isLoggedIn();

  /// 获取当前用户
  Future<User?> getCurrentUser();

  /// 登录
  Future<User> login(String username, String password);

  /// 登出
  Future<void> logout();
}

/// 认证仓库实现
class AuthRepositoryImpl implements AuthRepository {
  final MmkvDb _mmkv;
  final _logger = AppLogger.logger;

  AuthRepositoryImpl({required MmkvDb mmkv}) : _mmkv = mmkv;

  @override
  Future<bool> isLoggedIn() async {
    return _mmkv.get<bool>('isLoggedIn', false);
  }

  @override
  Future<User?> getCurrentUser() async {
    final username = _mmkv.get<String>('username', '');
    if (username.isNotEmpty) {
      final email = _mmkv.get<String>('email', '');
      final avatar = _mmkv.get<String>('avatar', '');
      return User(username: username, email: email, avatar: avatar);
    }
    return null;
  }

  @override
  Future<User> login(String username, String password) async {
    try {
      // 模拟登录验证（实际项目中应该调用 API）
      if (username.isEmpty || password.isEmpty) {
        throw Exception('用户名或密码不能为空');
      }

      // 模拟登录成功
      if (password.length >= 6) {
        final user = User(username: username, email: '$username@example.com');

        // 保存登录状态
        await _mmkv.put('isLoggedIn', true);
        await _mmkv.put('username', username);
        await _mmkv.put('email', user.email ?? '');

        _logger.d('用户登录成功: $username');
        return user;
      } else {
        throw Exception('密码长度至少6位');
      }
    } catch (e) {
      _logger.e('登录失败: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      // 清除登录状态
      _mmkv.remove('isLoggedIn');
      _mmkv.remove('username');
      _mmkv.remove('email');
      _mmkv.remove('avatar');

      _logger.d('用户已登出');
    } catch (e) {
      _logger.e('登出失败: $e');
      rethrow;
    }
  }
}
