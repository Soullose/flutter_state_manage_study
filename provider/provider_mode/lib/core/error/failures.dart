import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  /// Equatable 用于方便测试
  @override
  List<Object?> get props => [message];
}

/// 1. 服务器相关失败 (最常见)
class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message);
}

/// 2. 缓存相关失败
class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message);
}

/// 3. 认证相关失败 (可以进一步细化，例如 AuthFailure)
class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message);
}

/// 4. 其他通用失败 (如输入格式错误)
class InputFailure extends Failure {
  const InputFailure({required String message}) : super(message);
}
