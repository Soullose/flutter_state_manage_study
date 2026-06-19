import 'package:bloc_mode/core/error/failures.dart';
import 'package:bloc_mode/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:bloc_mode/features/chat/domain/repositories/chat_repository.dart';
import 'package:dart_either/dart_either.dart';

/// 实现 Domain 层的 [ChatRepository] 接口
///
/// 负责：
/// 1. 调用 DataSource 获取流式文本
/// 2. 将异常转换为 [Failure]
/// 3. 正常 token 以 [Right] 转发，异常以 [Left] 推送
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Stream<Either<Failure, String>> sendMessage(String userMessage) async* {
    try {
      await for (final chunk in remoteDataSource.sendMessage(userMessage)) {
        yield Right(chunk);
      }
    } catch (e) {
      yield Left(ServerFailure(message: e.toString()));
    }
  }
}
