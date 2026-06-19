import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider_mode/features/chat/domain/entities/chat_message.dart';
import 'package:provider_mode/features/chat/presentation/view/widgets/typing_indicator.dart';

/// 消息气泡
///
/// 用户消息：右侧、主题色背景、纯文本（可选）
/// 助手消息：左侧、表面色背景、Markdown 渲染，流式时末尾显示光标
class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  bool get _isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = _isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: _buildContent(context, theme, isUser),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, bool isUser) {
    // 用户消息：纯文本
    if (isUser) {
      return SelectableText(
        message.content,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onPrimary,
        ),
      );
    }

    // 助手消息：Markdown 渲染 + 流式光标
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        MarkdownBody(
          data: message.content.isEmpty && message.isStreaming
              ? ' '
              : message.content,
          selectable: !message.isStreaming,
          styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
            p: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            codeblockDecoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            code: TextStyle(
              color: theme.colorScheme.onSurface,
              fontFamily: 'monospace',
            ),
          ),
        ),
        if (message.isStreaming) ...[
          const SizedBox(width: 2),
          const TypingIndicator(),
        ],
      ],
    );
  }
}
