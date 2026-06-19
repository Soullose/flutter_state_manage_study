import 'package:dart_either/dart_either.dart';
import 'package:provider_mode/core/error/failures.dart';

/// 聊天仓库接口（Domain 层）
///
/// 这里定义了"我们要干什么"，但不关心"怎么干"。
/// 流式回复：返回 Stream，每个事件要么是 [Failure]（Left），
/// 要么是一段文本片段 token（Right）。
abstract class ChatRepository {
  /// 流式发送消息
  ///
  /// [userMessage] 用户输入文本
  /// 返回逐段推送的文本流
  Stream<Either<Failure, String>> sendMessage(String userMessage);
}
