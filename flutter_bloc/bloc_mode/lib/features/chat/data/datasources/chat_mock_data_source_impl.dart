import 'dart:async';

import 'package:bloc_mode/features/chat/data/datasources/chat_remote_data_source.dart';

/// Chat 远程数据源的 Mock 实现
///
/// 使用 [StreamController] + [Timer.periodic] 模拟逐 token 推送，
/// 完整复刻真实流式回复的体验，无需后端和 API Key。
class ChatMockDataSourceImpl implements ChatRemoteDataSource {
  /// 每个 token 推送间隔（毫秒）
  final int intervalMs;

  /// 首字延迟（毫秒），模拟"思考"时间
  final int initialDelayMs;

  ChatMockDataSourceImpl({
    this.intervalMs = 40,
    this.initialDelayMs = 400,
  });

  /// 预设回复模板，包含 Markdown 元素，便于演示流式渲染
  static const _replies = <String>[
    '你好！我是一个**流式回复**的示例助手。\n\n'
        '下面是打字机效果演示：\n\n'
        '- 第一，用户消息会**立即显示**\n'
        '- 第二，助手回复**逐字增长**\n'
        '- 第三，支持 *Markdown* 渲染\n\n'
        '一段代码示例：\n\n'
        '```dart\n'
        'void main() {\n'
        '  print("Hello, streaming!");\n'
        '}\n'
        '```\n\n'
        '希望这个示例对你有帮助！',
    '收到你的消息啦！\n\n'
        '这是一个基于 **Bloc + Clean Architecture** 的流式聊天示例：\n\n'
        '1. **Domain 层** 定义 `ChatRepository` 与 `SendMessage` 用例\n'
        '2. **Data 层** 提供 Mock 与 SSE 两种数据源\n'
        '3. **Presentation 层** 用 `ChatBloc` 订阅流并逐字刷新 UI\n\n'
        '> 打字机效果的本质：每收到一个 token 就 `emit` 新状态。',
    '这是一个很好的问题。\n\n'
        '流式回复的核心数据结构是 `Stream<String>`，它贯穿：\n\n'
        '```\n'
        'DataSource → Repository → UseCase → Bloc → UI\n'
        '```\n\n'
        '每一层都不阻塞，逐 token 向上传递，UI 因此呈现打字机动画。✨',
  ];

  @override
  Stream<String> sendMessage(String userMessage) {
    final controller = StreamController<String>();
    // 按用户输入内容轮换不同回复
    final reply = _replies[userMessage.hashCode.abs() % _replies.length];
    final chars = reply.runes.toList();
    var index = 0;
    Timer? timer;

    void emitToken(Timer t) {
      if (index >= chars.length) {
        t.cancel();
        if (!controller.isClosed) controller.close();
        return;
      }
      // 每次推送 1~2 个字符，模拟 token 切分
      final step = 1 + (index % 2);
      final end = (index + step > chars.length) ? chars.length : index + step;
      final chunk = String.fromCharCodes(chars.sublist(index, end));
      controller.add(chunk);
      index = end;
    }

    // 首字延迟后开始推送
    Future.delayed(Duration(milliseconds: initialDelayMs), () {
      if (controller.isClosed) return;
      timer = Timer.periodic(Duration(milliseconds: intervalMs), emitToken);
      // 立即触发一次首字
      emitToken(timer!);
    });

    // 监听取消（用户停止生成时）
    controller.onCancel = () {
      timer?.cancel();
      if (!controller.isClosed) controller.close();
    };

    return controller.stream;
  }
}
