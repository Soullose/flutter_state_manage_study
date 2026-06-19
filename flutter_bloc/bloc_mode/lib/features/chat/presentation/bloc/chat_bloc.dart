import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_mode/core/error/failures.dart';
import 'package:bloc_mode/features/chat/domain/entities/chat_message.dart';
import 'package:bloc_mode/features/chat/domain/usecases/send_message.dart';
import 'package:dart_either/dart_either.dart';
import 'package:uuid/uuid.dart';

import 'chat_event.dart';
import 'chat_state.dart';

/// 聊天 Bloc
///
/// 管理聊天消息列表与流式回复的 UI 状态，遵循 Bloc 模式。
///
/// **打字机效果的本质**：订阅数据源 [Stream] 后，每收到一个 token，
/// 通过 [ChatStreamChunkReceived] 事件重新投递给自身（参考 TimerBloc 的
/// `_TimerTicked`），在处理器中就地更新最后一条 assistant 消息的
/// [ChatMessage.content] 并 `emit`，UI 因此逐字增长。
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessage _sendMessage;
  final Uuid _uuid;

  ChatBloc({
    required SendMessage sendMessage,
    Uuid? uuid,
  })  : _sendMessage = sendMessage,
        _uuid = uuid ?? const Uuid(),
        super(const ChatInitial()) {
    on<ChatMessageSent>(_onMessageSent);
    on<ChatStreamChunkReceived>(_onChunkReceived);
    on<ChatStreamDone>(_onStreamDone);
    on<ChatGenerationStopped>(_onGenerationStopped);
    on<ChatMessagesCleared>(_onMessagesCleared);
  }

  StreamSubscription<Either<Failure, String>>? _subscription;

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  /// 当前消息列表（便于在处理器内读取，避免每个状态分支都解构）
  List<ChatMessage> get _currentMessages =>
      state.messages.toList(growable: true);

  /// 发送消息：添加 user + 空 assistant 消息，订阅数据源流
  void _onMessageSent(ChatMessageSent event, Emitter<ChatState> emit) {
    final content = event.content.trim();
    if (content.isEmpty || state.isGenerating) return;

    final messages = _currentMessages;

    // 1. 添加用户消息（立即显示）
    messages.add(ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.user,
      content: content,
      timestamp: DateTime.now(),
    ));

    // 2. 添加一条空的 assistant 消息作为流式容器（标记 isStreaming）
    messages.add(ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.assistant,
      content: '',
      timestamp: DateTime.now(),
      isStreaming: true,
    ));

    emit(ChatGenerating(messages: List.unmodifiable(messages)));

    // 3. 订阅数据源 Stream，逐 token 转为事件投递给自身
    _subscription?.cancel();
    _subscription = _sendMessage(SendMessageParams(content: content)).listen(
      (either) => add(ChatStreamChunkReceived(either)),
      onDone: () => add(const ChatStreamDone()),
      onError: (Object e) => add(
        ChatStreamChunkReceived(Left(ServerFailure(message: e.toString()))),
      ),
      cancelOnError: true,
    );
  }

  /// 处理一个 token 片段：正常则累加，失败则标记错误
  void _onChunkReceived(
    ChatStreamChunkReceived event,
    Emitter<ChatState> emit,
  ) {
    if (state.messages.isEmpty) return;
    final messages = _currentMessages;
    final lastIndex = messages.length - 1;
    final last = messages[lastIndex];

    event.chunk.fold(
      ifLeft: (failure) {
        // 错误：在内容末尾追加错误提示并标记
        final errorTip = '\n\n> ⚠️ ${_mapFailureToMessage(failure)}';
        messages[lastIndex] = last.copyWith(
          content:
              last.content.isEmpty ? errorTip.trim() : last.content + errorTip,
          isStreaming: false,
          hasError: true,
        );
      },
      ifRight: (chunk) {
        // 正常：累加 token
        messages[lastIndex] =
            last.copyWith(content: last.content + chunk);
      },
    );

    emit(ChatGenerating(messages: List.unmodifiable(messages)));
  }

  /// 流结束：取消最后一条消息的流式标记
  void _onStreamDone(ChatStreamDone event, Emitter<ChatState> emit) {
    final messages = _currentMessages;
    if (messages.isNotEmpty) {
      final lastIndex = messages.length - 1;
      final last = messages[lastIndex];
      if (last.isStreaming) {
        messages[lastIndex] = last.copyWith(isStreaming: false);
      }
    }
    _subscription?.cancel();
    _subscription = null;
    emit(ChatReady(messages: List.unmodifiable(messages)));
  }

  /// 停止生成（用户主动中断）
  void _onGenerationStopped(
    ChatGenerationStopped event,
    Emitter<ChatState> emit,
  ) {
    _subscription?.cancel();
    _subscription = null;
    // 复用 onStreamDone 收尾逻辑（取消流式标记并回到 Ready）
    _onStreamDone(const ChatStreamDone(), emit);
  }

  /// 清空所有消息
  void _onMessagesCleared(
    ChatMessagesCleared event,
    Emitter<ChatState> emit,
  ) {
    _subscription?.cancel();
    _subscription = null;
    emit(const ChatInitial());
  }

  /// 将 Failure 翻译为 UI 友好的错误信息
  String _mapFailureToMessage(Failure failure) {
    switch (failure) {
      case ServerFailure():
        return failure.message;
      case InputFailure():
        return failure.message;
      default:
        return '发生未知错误';
    }
  }
}
