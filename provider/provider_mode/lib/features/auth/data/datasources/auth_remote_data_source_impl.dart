import 'package:dio/dio.dart';
import 'package:provider_mode/features/auth/data/models/user_model.dart';

import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<UserModel> login(String email, String password) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<UserModel> register(String email, String password) {
    // TODO: implement register
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }
}
