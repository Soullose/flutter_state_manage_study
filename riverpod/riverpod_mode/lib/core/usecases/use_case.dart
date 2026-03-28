import 'package:dart_either/dart_either.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Type: 返回数据的类型 (例如 User)
/// Params: 需要传入的参数类型 (例如 LoginParams)
abstract class UseCase<T, P> {
  /// `Future<Either<Failure, T>>` 表示：结果要么是失败(左边)，要么是成功(右边)
  Future<Either<Failure, T>> call(P params);
}

/// 用于不需要任何参数的 Use Case
class NoParams extends Equatable {
  /// NoParams 是空的，所以 props 列表也是空的
  @override
  List<Object?> get props => [];
}
