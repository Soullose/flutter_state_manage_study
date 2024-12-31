
// 重试拦截器
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final int serverErrorCode;

  RetryInterceptor({
    required this.dio,
    required this.serverErrorCode,
    this.maxRetries = 3,
  });

  @override
  Future<void> onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    var extra = err.requestOptions.extra;
    var retryCount = extra['retryCount'] ?? 0;

    if (retryCount < maxRetries && _shouldRetry(err)) {
      retryCount += 1;
      extra['retryCount'] = retryCount;

      final options = Options(
        method: err.requestOptions.method,
        headers: err.requestOptions.headers,
        extra: extra,
      );

      try {
        final response = await dio.request(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: options,
        );
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }
    return handler.next(err);
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.response?.statusCode == serverErrorCode;
  }
}