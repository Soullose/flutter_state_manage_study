import 'package:flutter_test/flutter_test.dart';
import 'package:provider_mode/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:provider_mode/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:provider_mode/features/auth/domain/usecases/login_user.dart';
import 'package:provider_mode/features/auth/domain/usecases/logout_user.dart';
import 'package:provider_mode/features/auth/presentation/viewmodels/auth_view_model.dart';

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late AuthRepositoryImpl repository;
  late LoginUser loginUser;
  late LogoutUser logoutUser;
  late AuthViewModel authViewModel;

  setUp(() {
    dataSource = AuthRemoteDataSourceImpl(mockDelayMs: 10);
    repository = AuthRepositoryImpl(dataSource);
    loginUser = LoginUser(repository);
    logoutUser = LogoutUser(repository);
    authViewModel = AuthViewModel(
      loginUser: loginUser,
      logoutUser: logoutUser,
    );
  });

  group('AuthViewModel', () {
    test('初始状态应为未认证', () {
      expect(authViewModel.isAuthenticated, isFalse);
      expect(authViewModel.currentUser, isNull);
      expect(authViewModel.isLoading, isFalse);
      expect(authViewModel.errorMessage, isNull);
    });

    test('使用正确凭据登录应成功', () async {
      final result = await authViewModel.login(
        'test@example.com',
        '123456',
      );

      expect(result, isTrue);
      expect(authViewModel.isAuthenticated, isTrue);
      expect(authViewModel.currentUser, isNotNull);
      expect(authViewModel.currentUser!.email, 'test@example.com');
      expect(authViewModel.errorMessage, isNull);
    });

    test('使用错误密码登录应失败', () async {
      final result = await authViewModel.login(
        'test@example.com',
        'wrongpassword',
      );

      expect(result, isFalse);
      expect(authViewModel.isAuthenticated, isFalse);
      expect(authViewModel.errorMessage, isNotNull);
    });

    test('使用不存在用户登录应失败', () async {
      final result = await authViewModel.login(
        'nonexistent@example.com',
        '123456',
      );

      expect(result, isFalse);
      expect(authViewModel.isAuthenticated, isFalse);
    });

    test('登录时应显示加载状态', () async {
      final future = authViewModel.login('test@example.com', '123456');
      expect(authViewModel.isLoading, isTrue);
      await future;
      expect(authViewModel.isLoading, isFalse);
    });

    test('登出应清除用户状态', () async {
      // 先登录
      await authViewModel.login('test@example.com', '123456');
      expect(authViewModel.isAuthenticated, isTrue);

      // 登出
      await authViewModel.logout();
      expect(authViewModel.isAuthenticated, isFalse);
      expect(authViewModel.currentUser, isNull);
    });

    test('clearError 应清除错误消息', () async {
      await authViewModel.login('test@example.com', 'wrong');
      expect(authViewModel.errorMessage, isNotNull);

      authViewModel.clearError();
      expect(authViewModel.errorMessage, isNull);
    });
  });

  group('AuthRepositoryImpl', () {
    test('登录成功应返回 Right(User)', () async {
      final result = await repository.login('test@example.com', '123456');

      expect(result.isRight, isTrue);
      result.fold(
        ifLeft: (_) => fail('不应失败'),
        ifRight: (user) {
          expect(user.email, 'test@example.com');
        },
      );
    });

    test('登录失败应返回 Left(Failure)', () async {
      final result = await repository.login('bad', 'short');

      expect(result.isLeft, isTrue);
    });
  });
}
