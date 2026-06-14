import 'package:dart_either/dart_either.dart';
import 'package:provider_mode/core/error/failures.dart';
import 'package:provider_mode/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:provider_mode/features/auth/domain/entities/user.dart';
import 'package:provider_mode/features/auth/domain/repositories/auth_repository.dart';

/// 实现 Domain 层的 AuthRepository 接口
///
/// 负责：
/// 1. 调用 DataSource 获取数据
/// 2. 将 Model 转换为 Domain Entity
/// 3. 捕获异常并转换为 Failure
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      return Right(userModel.toEntity());
    } on ArgumentError catch (e) {
      return Left(InputFailure(message: e.message));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }
}
