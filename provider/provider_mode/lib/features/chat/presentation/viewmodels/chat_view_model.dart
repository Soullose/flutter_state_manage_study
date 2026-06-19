import 'dart:async';

import 'package:dart_either/dart_either.dart';
import 'package:flutter/foundation.dart';
import 'package:provider_mode/core/error/failures.dart';
import 'package:provider_mode/features/chat/domain/entities/chat_message.dart';
import 'package:provider_mode/features/chat/domain/usecases/send_message.dart';
import 'package:uuid/uuid.dart';

/// 聊天状态管理 ViewModel
///
/// 负责管理聊天消息列表与流式回复的 UI 状态，遵循 Provider 模式。
///
/// **打字机效果的本质**：每收到一个 token，就就地更新最后一条
/// assistant 消息的 [ChatMessage.content]，并调用 [notifyListeners]，
/// UI 通过 [Consumer] 重建，呈现逐字增长效果。
class ChatViewModel extends ChangeNotifier {
  final SendMessage _sendMessage;
  final Uuid _uuid;

  ChatViewModel({
    required SendMessage sendMessage,
    Uuid? uuid,
  })  : _sendMessage = sendMessage,
        _uuid = uuid ?? const Uuid();

  // --- 状态属性 ---
  final List<ChatMessage> _messages = [];
  StreamSubscription<Either<Failure, String>>? _subscription;
  bool _isGenerating = false;

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isGenerating => _isGenerating;
  bool get isEmpty => _messages.isEmpty;

  /// 发送消息，触发流式回复
  void send(String text) {
    final content = text.trim();
    if (content.isEmpty || _isGenerating) return;

    // 1. 添加用户消息（立即显示）
    _messages.add(ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.user,
      content: content,
      timestamp: DateTime.now(),
    ));

    // 2. 添加一条空的 assistant 消息作为流式容器（标记 isStreaming）
    _messages.add(ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.assistant,
      content: '',
      timestamp: DateTime.now(),
      isStreaming: true,
    ));

    _isGenerating = true;
    notifyListeners();

    // 3. 订阅数据源 Stream，逐 token 累加到最后一条消息
    _subscription = _sendMessage(SendMessageParams(content: content)).listen(
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
    if (_messages.isEmpty) return;
    final lastIndex = _messages.length - 1;
    final last = _messages[lastIndex];
    _messages[lastIndex] = last.copyWith(content: last.content + chunk);
    notifyListeners();
  }

  /// 处理流式错误：标记最后一条消息为错误状态
  void _onStreamError(Failure failure) {
    if (_messages.isEmpty) return;
    final lastIndex = _messages.length - 1;
    final last = _messages[lastIndex];
    final errorTip = '\n\n> ⚠️ ${_mapFailureToMessage(failure)}';
    _messages[lastIndex] = last.copyWith(
      content: last.content.isEmpty ? errorTip.trim() : last.content + errorTip,
      isStreaming: false,
      hasError: true,
    );
    _isGenerating = false;
    notifyListeners();
  }

  /// 流结束：取消流式标记
  void _onStreamDone() {
    if (_messages.isNotEmpty) {
      final lastIndex = _messages.length - 1;
      final last = _messages[lastIndex];
      if (last.isStreaming) {
        _messages[lastIndex] = last.copyWith(isStreaming: false);
      }
    }
    _isGenerating = false;
    notifyListeners();
  }

  /// 停止生成（用户主动中断）
  void stopGeneration() {
    _subscription?.cancel();
    _subscription = null;
    _onStreamDone();
  }

  /// 清空所有消息
  void clearMessages() {
    if (_isGenerating) {
      stopGeneration();
    }
    _messages.clear();
    notifyListeners();
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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
