import 'package:provider_mode/features/chat/domain/entities/chat_message.dart';

/// 聊天消息数据层模型
///
/// 负责 JSON 序列化/反序列化，以及向 Domain 层 Entity 的转换
class ChatMessageModel {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isStreaming;
  final bool hasError;

  const ChatMessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isStreaming = false,
    this.hasError = false,
  });

  /// 从 JSON 创建
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      role: MessageRole.values.byName(json['role'] as String),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isStreaming: (json['isStreaming'] as bool?) ?? false,
      hasError: (json['hasError'] as bool?) ?? false,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isStreaming': isStreaming,
      'hasError': hasError,
    };
  }

  /// 转换为 Domain 层 Entity
  ChatMessage toEntity() {
    return ChatMessage(
      id: id,
      role: role,
      content: content,
      timestamp: timestamp,
      isStreaming: isStreaming,
      hasError: hasError,
    );
  }

  /// 从 Domain 层 Entity 创建 Model
  factory ChatMessageModel.fromEntity(ChatMessage entity) {
    return ChatMessageModel(
      id: entity.id,
      role: entity.role,
      content: entity.content,
      timestamp: entity.timestamp,
      isStreaming: entity.isStreaming,
      hasError: entity.hasError,
    );
  }
}
