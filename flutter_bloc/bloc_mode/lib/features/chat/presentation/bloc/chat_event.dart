import 'package:bloc_mode/core/error/failures.dart';
import 'package:dart_either/dart_either.dart';
import 'package:equatable/equatable.dart';

/// 聊天事件基类
sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// 用户发送消息
class ChatMessageSent extends ChatEvent {
  final String content;

  const ChatMessageSent(this.content);

  @override
  List<Object?> get props => [content];
}

/// 停止生成（用户主动中断）
class ChatGenerationStopped extends ChatEvent {
  const ChatGenerationStopped();
}

/// 清空所有消息
class ChatMessagesCleared extends ChatEvent {
  const ChatMessagesCleared();
}

/// 流式收到一个 token 片段（内部事件，由 StreamSubscription 派发）
///
/// 对应 [package:bloc_mode/features/timer/bloc/timer_bloc.dart] 中的
/// `_TimerTicked`：Bloc 订阅流后，将每个 chunk 转为事件重新投递给自己。
class ChatStreamChunkReceived extends ChatEvent {
  final Either<Failure, String> chunk;

  const ChatStreamChunkReceived(this.chunk);

  @override
  List<Object?> get props => [chunk];
}

/// 流结束（内部事件）
class ChatStreamDone extends ChatEvent {
  const ChatStreamDone();
}
