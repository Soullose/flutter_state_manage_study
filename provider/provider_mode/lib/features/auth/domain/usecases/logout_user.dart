import 'package:dart_either/src/dart_either.dart';
import 'package:provider_mode/core/error/failures.dart';
import 'package:provider_mode/core/usecases/use_case.dart';
import 'package:provider_mode/features/auth/domain/repositories/auth_repository.dart';

class LogoutUser implements UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUser(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    repository.logout();
    throw UnimplementedError();
  }
}
