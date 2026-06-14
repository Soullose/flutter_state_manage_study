import 'package:dart_either/dart_either.dart';
import 'package:equatable/equatable.dart';
import 'package:provider_mode/core/error/failures.dart';
import 'package:provider_mode/core/usecases/use_case.dart';
import 'package:provider_mode/features/auth/domain/entities/user.dart';
import 'package:provider_mode/features/auth/domain/repositories/auth_repository.dart';

/// 登录用例
///
/// 接收 [LoginParams]，返回 [User] 或 [Failure]
class LoginUser implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  LoginUser(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return repository.login(params.email, params.password);
  }
}

/// 登录参数
class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
