/// Chat 远程数据源抽象接口
///
/// 流式回复：返回逐段文本的 [Stream]。
/// 具体实现可切换为 Mock 或真实 SSE 接口。
abstract class ChatRemoteDataSource {
  /// 流式发送消息，返回逐段文本片段
  Stream<String> sendMessage(String userMessage);
}
