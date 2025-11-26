import 'package:dart_either/dart_either.dart';
import 'package:provider_mode/core/error/failures.dart';
import 'package:provider_mode/features/auth/domain/entities/user.dart';

/// 这里定义了“我们要干什么”，但不关心“怎么干”
abstract class AuthRepository {
  /// 登录：成功返回 User 实体，失败返回 Failure
  Future<Either<Failure, User>> login(String email, String password);

  /// 登出
  Future<Either<Failure, void>> logout();
}
