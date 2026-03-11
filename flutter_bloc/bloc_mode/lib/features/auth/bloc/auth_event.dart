import 'package:equatable/equatable.dart';

/// 认证事件基类
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// 应用启动时检查认证状态
class AuthStarted extends AuthEvent {
  const AuthStarted();

  @override
  List<Object?> get props => [];
}

/// 用户登录事件
class AuthLoggedIn extends AuthEvent {
  final String username;
  final String password;

  const AuthLoggedIn(this.username, this.password);

  @override
  List<Object?> get props => [username, password];
}

/// 用户登出事件
class AuthLoggedOut extends AuthEvent {
  const AuthLoggedOut();

  @override
  List<Object?> get props => [];
}

/// 检查认证状态事件
class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();

  @override
  List<Object?> get props => [];
}
