import 'package:dart_either/src/dart_either.dart';
import 'package:equatable/equatable.dart';
import 'package:provider_mode/core/error/failures.dart';
import 'package:provider_mode/core/usecases/use_case.dart';
import 'package:provider_mode/features/auth/domain/entities/user.dart';
import 'package:provider_mode/features/auth/domain/repositories/auth_repository.dart';

class LoginUser implements UseCase<User, LoginParams> {
  /// 注入依赖
  final AuthRepository repository;

  LoginUser(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) {
    final email = params.email;
    final password = params.password;
    repository.login(email, password);
    throw UnimplementedError();
  }
}

/// 定义参数类（使用 Equatable 以方便比较和测试）
class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
