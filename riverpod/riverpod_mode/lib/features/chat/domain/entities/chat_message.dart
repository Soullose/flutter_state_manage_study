import 'package:equatable/equatable.dart';

/// 消息角色
enum MessageRole {
  user,
  assistant,
}

/// 聊天消息业务实体
///
/// Domain 层使用的纯 Dart 对象，不依赖任何框架或数据层。
/// 流式回复时，助手消息会通过 [copyWith] 逐 token 累加 [content]。
class ChatMessage extends Equatable {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;

  /// 是否正在流式接收（用于控制打字光标显示）
  final bool isStreaming;

  /// 是否出错（流式过程中发生错误）
  final bool hasError;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isStreaming = false,
    this.hasError = false,
  });

  /// 复制并修改部分字段（流式累加时使用）
  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    bool? isStreaming,
    bool? hasError,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      hasError: hasError ?? this.hasError,
    );
  }

  @override
  List<Object?> get props =>
      [id, role, content, timestamp, isStreaming, hasError];
}
