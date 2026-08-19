import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import 'chat_page.dart';

/// 聊天主体视图
///
/// 展示 Riverpod 在流式场景中的使用：
/// - [ref.watch] 监听消息列表变化（逐 token 刷新）
/// - [ref.read] 触发发送/停止/清空
/// - 自动滚动到底部，跟随流式输出
class ChatView extends ConsumerStatefulWidget {
  const ChatView({super.key});

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
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

  void _handleSend(bool isGenerating) {
    final text = _inputController.text.trim();
    if (text.isEmpty || isGenerating) return;
    ref.read(chatControllerProvider.notifier).send(text);
    _inputController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    final isGenerating = chatState.isGenerating;

    // 消息变化时滚动到底部
    if (chatState.messages.isNotEmpty) {
      _scrollToBottom();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'hero_/chat',
              flightShuttleBuilder: ChatPage.flightShuttleBuilder,
              child: const Icon(Icons.chat_outlined),
            ),
            const SizedBox(width: 8),
            const Text('流式聊天'),
          ],
        ),
        centerTitle: true,
        actions: [
          if (chatState.messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: '清空',
              onPressed: isGenerating
                  ? null
                  : () => _confirmClear(context),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 消息列表
            Expanded(
              child: chatState.isEmpty
                  ? _buildEmptyHint(context)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      itemCount: chatState.messages.length,
                      itemBuilder: (context, index) {
                        return MessageBubble(message: chatState.messages[index]);
                      },
                    ),
            ),
            // 输入栏
            _buildInputBar(context, isGenerating),
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
  Widget _buildInputBar(BuildContext context, bool isGenerating) {
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
                enabled: !isGenerating,
                onSubmitted: (_) => _handleSend(isGenerating),
                decoration: InputDecoration(
                  hintText: isGenerating ? '正在生成回复…' : '输入消息',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 生成中显示停止按钮，否则显示发送按钮
            isGenerating
                ? _buildStopButton(context)
                : _buildSendButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _inputController,
      builder: (context, value, _) {
        final enabled = value.text.trim().isNotEmpty;
        return IconButton.filled(
          icon: const Icon(Icons.send),
          iconSize: 20,
          onPressed: enabled ? () => _handleSend(false) : null,
          tooltip: '发送',
        );
      },
    );
  }

  Widget _buildStopButton(BuildContext context) {
    return IconButton.filled(
      icon: const Icon(Icons.stop),
      iconSize: 20,
      onPressed: () => ref.read(chatControllerProvider.notifier).stopGeneration(),
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
    if (confirmed == true) {
      ref.read(chatControllerProvider.notifier).clearMessages();
    }
  }
}
