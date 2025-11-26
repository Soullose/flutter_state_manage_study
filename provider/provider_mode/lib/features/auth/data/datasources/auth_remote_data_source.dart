import 'package:provider_mode/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);

  Future<void> logout();

  Future<UserModel> register(String email, String password);
}
