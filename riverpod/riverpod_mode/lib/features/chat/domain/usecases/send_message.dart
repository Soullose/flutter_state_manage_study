import 'package:dart_either/dart_either.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/stream_use_case.dart';
import '../repositories/chat_repository.dart';

/// 发送消息用例
///
/// 接收 [SendMessageParams]，返回流式文本片段，逐 token 向上传递。
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
