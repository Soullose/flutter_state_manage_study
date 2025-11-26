import 'package:dart_either/src/dart_either.dart';
import 'package:provider_mode/core/error/failures.dart';
import 'package:provider_mode/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:provider_mode/features/auth/domain/entities/user.dart';
import 'package:provider_mode/features/auth/domain/repositories/auth_repository.dart';

/// 实现 Domain 层的接口
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    // 2. 调用数据源 (DataSource 返回的是 Model)
    final userModel = await remoteDataSource.login(email, password);
    return Right(userModel as User);
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // TODO: implement logout
    await remoteDataSource.logout();
    throw UnimplementedError();
  }
}
