import 'package:bloc_mode/core/storage/shared_preferences_utils.dart';
import 'package:bloc_mode/features/auth/models/user.dart';
import 'package:logger/logger.dart';

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
  final SharedPreferencesUtils _prefs;
  final Logger _logger = Logger();

  AuthRepositoryImpl({required SharedPreferencesUtils prefs}) : _prefs = prefs;

  @override
  Future<bool> isLoggedIn() async {
    return _prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Future<User?> getCurrentUser() async {
    final username = _prefs.getString('username');
    if (username != null && username.isNotEmpty) {
      final email = _prefs.getString('email');
      final avatar = _prefs.getString('avatar');
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
        await _prefs.setBool('isLoggedIn', true);
        await _prefs.setString('username', username);
        await _prefs.setString('email', user.email ?? '');

        _logger.i('用户登录成功: $username');
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
      await _prefs.remove('isLoggedIn');
      await _prefs.remove('username');
      await _prefs.remove('email');
      await _prefs.remove('avatar');

      _logger.i('用户已登出');
    } catch (e) {
      _logger.e('登出失败: $e');
      rethrow;
    }
  }
}
