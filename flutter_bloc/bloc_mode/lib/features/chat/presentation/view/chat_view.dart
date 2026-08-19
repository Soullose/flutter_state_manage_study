import 'package:bloc_mode/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:bloc_mode/features/chat/presentation/bloc/chat_event.dart';
import 'package:bloc_mode/features/chat/presentation/bloc/chat_state.dart';
import 'package:bloc_mode/features/chat/presentation/view/widgets/message_bubble.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// 聊天主体视图
///
/// 展示 Bloc 在流式场景中的使用：
/// - [BlocBuilder] 监听状态变化（逐 token 刷新）
/// - [context.read] 触发发送/停止/清空
/// - 自动滚动到底部，跟随流式输出
class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 滚动到底部（跟随最新消息 / 流式输出）
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleSend(ChatBloc bloc) {
    final text = _inputController.text.trim();
    if (text.isEmpty || bloc.state.isGenerating) return;
    bloc.add(ChatMessageSent(text));
    _inputController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('流式聊天'),
        centerTitle: true,
        actions: [
          BlocBuilder<ChatBloc, ChatState>(
            buildWhen: (previous, current) =>
                previous.isEmpty != current.isEmpty,
            builder: (context, state) {
              if (state.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: '清空',
                onPressed: state.isGenerating
                    ? null
                    : () => _confirmClear(context),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 消息列表
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                buildWhen: (previous, current) {
                  // 消息数量或最后一条内容变化时重建
                  if (previous.messages.length !=
                      current.messages.length) {
                    return true;
                  }
                  if (previous.isGenerating != current.isGenerating) {
                    return true;
                  }
                  if (current.messages.isEmpty) {
                    return false;
                  }
                  return previous.messages.last != current.messages.last;
                },
                builder: (context, state) {
                  // 消息数量变化时滚动到底部
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (state.messages.isNotEmpty) {
                      _scrollToBottom();
                    }
                  });

                  if (state.isEmpty) {
                    return _buildEmptyHint(context);
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(message: state.messages[index]);
                    },
                  );
                },
              ),
            ),
            // 输入栏
            _buildInputBar(context),
          ],
        ),
      ),
    );
  }

  /// 空状态提示
  Widget _buildEmptyHint(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.smart_toy_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '开始一段对话吧',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '输入消息，体验仿 ChatGPT 的打字机流式回复',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  /// 底部输入栏
  Widget _buildInputBar(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (previous, current) =>
          previous.isGenerating != current.isGenerating,
      builder: (context, state) {
        final bloc = context.read<ChatBloc>();
        return Container(
          padding: const EdgeInsets.only(
            left: 12,
            right: 8,
            top: 8,
            bottom: 8,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    focusNode: _focusNode,
                    maxLines: 5,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    enabled: !state.isGenerating,
                    onSubmitted: (_) => _handleSend(bloc),
                    decoration: InputDecoration(
                      hintText:
                          state.isGenerating ? '正在生成回复…' : '输入消息',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 生成中显示停止按钮，否则显示发送按钮
                state.isGenerating
                    ? _buildStopButton(context, bloc)
                    : _buildSendButton(context, bloc),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSendButton(BuildContext context, ChatBloc bloc) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _inputController,
      builder: (context, value, _) {
        final enabled = value.text.trim().isNotEmpty;
        return IconButton.filled(
          icon: const Icon(Icons.send),
          iconSize: 20,
          onPressed: enabled ? () => _handleSend(bloc) : null,
          tooltip: '发送',
        );
      },
    );
  }

  Widget _buildStopButton(BuildContext context, ChatBloc bloc) {
    return IconButton.filled(
      icon: const Icon(Icons.stop),
      iconSize: 20,
      onPressed: () => bloc.add(const ChatGenerationStopped()),
      tooltip: '停止生成',
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空对话'),
        content: const Text('确定要清空所有消息吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('清空'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ChatBloc>().add(const ChatMessagesCleared());
    }
  }
}
