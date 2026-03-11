import 'package:equatable/equatable.dart';
import '../models/user.dart';

/// 认证状态基类
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  List<Object?> get props => [];
}

/// 加载中状态
class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  List<Object?> get props => [];
}

/// 已认证状态
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// 未认证状态
class Unauthenticated extends AuthState {
  const Unauthenticated();

  @override
  List<Object?> get props => [];
}

/// 认证失败状态
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
