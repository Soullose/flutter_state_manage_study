import 'package:dart_either/dart_either.dart';
import 'package:equatable/equatable.dart';
import 'package:provider_mode/core/error/failures.dart';
import 'package:provider_mode/features/chat/domain/repositories/chat_repository.dart';

/// 流式用例基类
///
/// 与 [UseCase]（返回 Future）不同，流式场景返回 [Stream]，
/// 以便逐 token 推送给上层。
abstract class StreamUseCase<T, P> {
  Stream<Either<Failure, T>> call(P params);
}

/// 发送消息用例
///
/// 接收 [SendMessageParams]，返回流式文本片段
class SendMessage implements StreamUseCase<String, SendMessageParams> {
  final ChatRepository repository;

  SendMessage(this.repository);

  @override
  Stream<Either<Failure, String>> call(SendMessageParams params) {
    return repository.sendMessage(params.content);
  }
}

/// 发送消息参数
class SendMessageParams extends Equatable {
  final String content;

  const SendMessageParams({required this.content});

  @override
  List<Object?> get props => [content];
}
