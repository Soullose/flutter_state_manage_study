/// Chat 远程数据源接口（Data 层）
///
/// 定义流式回复的数据来源契约。具体实现可以是：
/// - [ChatMockDataSourceImpl]：用 Timer 模拟逐 token 推送，无需后端和 API Key
/// - [ChatSseDataSourceImpl]：接入 OpenAI 兼容的 Chat Completions 流式接口
///
/// 数据源返回的 [Stream<String>] 是原始 token 片段，
/// 由 Repository 包装成 `Either<Failure, String>` 后向上传递。
abstract class ChatRemoteDataSource {
  /// 流式发送消息，返回逐段推送的文本流
  Stream<String> sendMessage(String userMessage);
}
