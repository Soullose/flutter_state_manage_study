import 'package:dart_either/dart_either.dart';

import '../error/failures.dart';

/// 流式用例基类
///
/// 与 [UseCase]（返回 Future）不同，流式场景返回 [Stream]，
/// 以便逐 token 推送给上层，实现仿 ChatGPT 的打字机效果。
///
/// Type: 返回数据的类型（例如 String token 片段）
/// P: 需要传入的参数类型（例如 SendMessageParams）
abstract class StreamUseCase<T, P> {
  /// `Stream<Either<Failure, T>>` 表示：每个事件要么是失败(左边)，
  /// 要么是成功数据(右边)，逐段向上传递。
  Stream<Either<Failure, T>> call(P params);
}
