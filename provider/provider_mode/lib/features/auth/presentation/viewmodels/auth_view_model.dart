import 'package:flutter/material.dart';
import 'package:provider_mode/core/error/failures.dart';
import 'package:provider_mode/features/auth/domain/entities/user.dart';
import 'package:provider_mode/features/auth/domain/usecases/login_user.dart';

class AuthViewModel extends ChangeNotifier {
  final LoginUser loginUser;

  AuthViewModel({required this.loginUser});

  // --- 状态属性 ---
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  // 提供给 UI 层访问的 Getters
  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  // 响应 UI 事件的方法：执行登录操作
  Future<void> login(String email, String password) async {
    // 步骤一：清空错误信息，设置为加载状态，并通知监听者
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    // 步骤二：调用 Use Case
    final params = LoginParams(email: email, password: password);
    final result = await loginUser(params);

    // 步骤三：处理 Either<Failure, User> 的结果
    result.fold(
      ifLeft: (Failure value) {
        /// 处理失败
      },
      ifRight: (User value) {
        /// 处理成功
      },
    );

    // 步骤四：无论成功或失败，都解除加载状态，并通知 UI 更新
    _isLoading = false;
    notifyListeners();
  }

  // 辅助函数：将 Failure 对象翻译成 UI 友好的错误信息 (与 BLoC 中相同)
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return failure.message ?? '服务器连接失败，请检查网络';
      case AuthFailure _:
        return failure.message ?? '账号或密码错误';
      // ... 其他 Failure
      default:
        return '发生未知错误';
    }
  }
}
