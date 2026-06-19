import 'dart:async';
import 'dart:convert';

import 'package:bloc_mode/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:dio/dio.dart';

/// Chat 远程数据源的 SSE 实现
///
/// 使用 [Dio] 的流式响应（`ResponseType.stream`）接入
/// OpenAI 兼容的 Chat Completions 接口（`/v1/chat/completions`，`stream: true`）。
///
/// 默认不启用。若需切换到真实接口，在 DI 中替换 [ChatMockDataSourceImpl]。
class ChatSseDataSourceImpl implements ChatRemoteDataSource {
  final Dio _dio;
  final String model;

  ChatSseDataSourceImpl({
    required String baseUrl,
    required String apiKey,
    this.model = 'gpt-3.5-turbo',
    Dio? dio,
  }) : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              headers: {
                'Authorization': 'Bearer $apiKey',
                'Content-Type': 'application/json',
                'Accept': 'text/event-stream',
              },
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(minutes: 5),
            ));

  @override
  Stream<String> sendMessage(String userMessage) async* {
    final Response<ResponseBody> response;
    try {
      response = await _dio.post<ResponseBody>(
        '/v1/chat/completions',
        data: {
          'model': model,
          'stream': true,
          'messages': [
            {'role': 'user', 'content': userMessage},
          ],
        },
        options: Options(responseType: ResponseType.stream),
      );
    } catch (e) {
      throw Exception('SSE 请求失败: $e');
    }

    final stream = response.data!.stream;
    String pending = '';

    // 按 SSE 协议解析：以 `data: ` 开头，空行分隔事件
    await for (final List<int> chunk in stream) {
      pending += utf8.decode(chunk);
      final lines = pending.split('\n');
      // 最后一段可能不完整，暂存到 pending
      pending = lines.removeLast();

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith(':')) continue; // 注释/心跳
        if (!trimmed.startsWith('data:')) continue;

        final data = trimmed.substring(5).trim();
        // 流结束标志
        if (data == '[DONE]') return;

        // 解析 OpenAI delta.content
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final choices = json['choices'] as List<dynamic>?;
          if (choices == null || choices.isEmpty) continue;
          final delta = choices[0]['delta'] as Map<String, dynamic>?;
          final content = delta?['content'] as String?;
          if (content != null && content.isNotEmpty) {
            yield content;
          }
        } catch (_) {
          // 跳过无法解析的事件
          continue;
        }
      }
    }
  }
}
