import 'dart:async';

import 'package:dart_either/dart_either.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../features/setting/riverpod/setting.dart';
import '../../data/datasources/chat_mock_data_source_impl.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/datasources/chat_sse_data_source_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/send_message.dart';

part 'chat_provider.g.dart';

/// 聊天 UI 状态
class ChatState {
  /// 消息列表（用户 + 助手）
  final List<ChatMessage> messages;

  /// 是否正在生成回复
  final bool isGenerating;

  const ChatState({
    this.messages = const [],
    this.isGenerating = false,
  });

  bool get isEmpty => messages.isEmpty;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isGenerating,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }
}

/// 数据源 Provider
///
/// 根据设置页的 `useMock` 切换 Mock / SSE 实现。
/// 监听 [settingProvider]，配置变更时自动重建。
@riverpod
ChatRemoteDataSource chatRemoteDataSource(Ref ref) {
  final setting = ref.watch(settingProvider).value;
  final useMock = setting?.useMock ?? true;

  if (useMock) {
    return ChatMockDataSourceImpl();
  }

  return ChatSseDataSourceImpl(
    baseUrl: setting?.apiBaseUrl ?? 'https://api.openai.com',
    apiKey: setting?.apiKey ?? '',
    model: setting?.apiModel ?? 'gpt-3.5-turbo',
  );
}

/// 仓库 Provider
@riverpod
ChatRepository chatRepository(Ref ref) {
  return ChatRepositoryImpl(ref.watch(chatRemoteDataSourceProvider));
}

/// 发送消息用例 Provider
@riverpod
SendMessage sendMessage(Ref ref) {
  return SendMessage(ref.watch(chatRepositoryProvider));
}

/// 聊天状态控制器
///
/// 负责管理消息列表与流式回复的 UI 状态，遵循 Riverpod 模式。
///
/// **打字机效果的本质**：每收到一个 token，就就地更新最后一条
/// assistant 消息的 [ChatMessage.content]，并更新 state，
/// UI 通过 [ref.watch] 重建，呈现逐字增长效果。
///
/// 流式订阅在用户点击发送时才建立（命令式），
/// 因此用普通 AsyncNotifier + 手动 [StreamSubscription]，
/// 而非 StreamNotifierProvider（build 即订阅，语义不契合）。
@riverpod
class ChatController extends _$ChatController {
  final Uuid _uuid = const Uuid();
  StreamSubscription<Either<Failure, String>>? _subscription;

  @override
  ChatState build() {
    // 生命周期结束时取消流式订阅
    ref.onDispose(() {
      _subscription?.cancel();
    });
    return const ChatState();
  }

  /// 发送消息，触发流式回复
  void send(String text) {
    final content = text.trim();
    if (content.isEmpty || state.isGenerating) return;

    final now = DateTime.now();

    // 1. 添加用户消息（立即显示）
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.user,
      content: content,
      timestamp: now,
    );

    // 2. 添加一条空的 assistant 消息作为流式容器（标记 isStreaming）
    final assistantMessage = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.assistant,
      content: '',
      timestamp: now,
      isStreaming: true,
    );

    state = ChatState(
      messages: [...state.messages, userMessage, assistantMessage],
      isGenerating: true,
    );

    // 3. 订阅数据源 Stream，逐 token 累加到最后一条消息
    final sendMessageUseCase = ref.read(sendMessageProvider);
    _subscription = sendMessageUseCase(SendMessageParams(content: content)).listen(
      (either) => either.fold(
        ifLeft: _onStreamError,
        ifRight: _onStreamChunk,
      ),
      onDone: _onStreamDone,
      onError: (Object e) => _onStreamError(
        ServerFailure(message: e.toString()),
      ),
      cancelOnError: true,
    );
  }

  /// 处理一个 token 片段：累加到最后一条消息并刷新
  void _onStreamChunk(String chunk) {
    final messages = [...state.messages];
    if (messages.isEmpty) return;
    final lastIndex = messages.length - 1;
    final last = messages[lastIndex];
    messages[lastIndex] = last.copyWith(content: last.content + chunk);
    state = state.copyWith(messages: messages);
  }

  /// 处理流式错误：标记最后一条消息为错误状态
  void _onStreamError(Failure failure) {
    final messages = [...state.messages];
    if (messages.isEmpty) return;
    final lastIndex = messages.length - 1;
    final last = messages[lastIndex];
    final errorTip = '\n\n> ⚠️ ${_mapFailureToMessage(failure)}';
    messages[lastIndex] = last.copyWith(
      content: last.content.isEmpty ? errorTip.trim() : last.content + errorTip,
      isStreaming: false,
      hasError: true,
    );
    state = ChatState(messages: messages, isGenerating: false);
  }

  /// 流结束：取消流式标记
  void _onStreamDone() {
    final messages = [...state.messages];
    if (messages.isNotEmpty) {
      final lastIndex = messages.length - 1;
      final last = messages[lastIndex];
      if (last.isStreaming) {
        messages[lastIndex] = last.copyWith(isStreaming: false);
      }
    }
    state = ChatState(messages: messages, isGenerating: false);
  }

  /// 停止生成（用户主动中断）
  void stopGeneration() {
    _subscription?.cancel();
    _subscription = null;
    _onStreamDone();
  }

  /// 清空所有消息
  void clearMessages() {
    if (state.isGenerating) {
      stopGeneration();
    }
    state = const ChatState();
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
