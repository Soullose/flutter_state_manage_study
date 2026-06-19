import 'package:bloc_mode/features/chat/domain/entities/chat_message.dart';
import 'package:equatable/equatable.dart';

/// 聊天状态基类
///
/// 所有状态统一携带 [messages]，便于 UI 无条件读取消息列表，
/// 无需在不同状态间做空判断。
sealed class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool isGenerating;

  const ChatState({
    this.messages = const [],
    this.isGenerating = false,
  });

  /// 是否还没有任何消息
  bool get isEmpty => messages.isEmpty;

  @override
  List<Object?> get props => [messages, isGenerating];
}

/// 初始状态（空消息列表）
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// 正在生成回复（流式接收中）
class ChatGenerating extends ChatState {
  const ChatGenerating({required super.messages});
}

/// 空闲状态（可发送下一条消息）
class ChatReady extends ChatState {
  const ChatReady({required super.messages});
}
