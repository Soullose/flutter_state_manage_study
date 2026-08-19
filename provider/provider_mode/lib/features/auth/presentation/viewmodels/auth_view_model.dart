import 'package:material_ui/material_ui.dart';
import 'package:provider_mode/core/error/failures.dart';
import 'package:provider_mode/core/usecases/use_case.dart';
import 'package:provider_mode/features/auth/domain/entities/user.dart';
import 'package:provider_mode/features/auth/domain/usecases/login_user.dart';
import 'package:provider_mode/features/auth/domain/usecases/logout_user.dart';

/// 认证状态管理 ViewModel
///
/// 负责管理登录/登出的 UI 状态，遵循 Provider 模式
class AuthViewModel extends ChangeNotifier {
  final LoginUser _loginUser;
  final LogoutUser _logoutUser;

  AuthViewModel({
    required LoginUser loginUser,
    required LogoutUser logoutUser,
  })  : _loginUser = loginUser,
        _logoutUser = logoutUser;

  // --- 状态属性 ---
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  /// 执行登录
  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    final params = LoginParams(email: email, password: password);
    final result = await _loginUser(params);

    result.fold(
      ifLeft: (Failure failure) {
        _errorMessage = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      ifRight: (User user) {
        _currentUser = user;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
      },
    );

    return _currentUser != null;
  }

  /// 执行登出
  Future<void> logout() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    final result = await _logoutUser(NoParams());

    result.fold(
      ifLeft: (Failure failure) {
        _errorMessage = _mapFailureToMessage(failure);
      },
      ifRight: (_) {
        _currentUser = null;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// 清除错误消息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 将 Failure 翻译为 UI 友好的错误信息
  String _mapFailureToMessage(Failure failure) {
    switch (failure) {
      case ServerFailure():
        return failure.message;
      case AuthFailure():
        return failure.message;
      case InputFailure():
        return failure.message;
      default:
        return '发生未知错误';
    }
  }
}
