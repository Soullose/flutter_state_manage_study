import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_mode/common/net/result_data.dart';

import 'interceptors/cookie_interceptors.dart';
import 'interceptors/error_interceptors.dart';
import 'interceptors/header_interceptor.dart';
import 'interceptors/response_interceptors.dart';

part 'http_manager.g.dart';

@riverpod
class HttpManager extends _$HttpManager {
  static const Duration _defaultConnectTimeout = Duration(seconds: 10);
  static const Duration _defaultReceiveTimeout = Duration(seconds: 10);
  static const Duration _defaultSendTimeout = Duration(seconds: 10);
  // static const int _maxRetries = 3;

  // 定义API错误码
  static const int successCode = 200;
  static const int authErrorCode = 401;
  static const int serverErrorCode = 400;

  // 取消令牌存储
  final Map<String, CancelToken> _cancelTokens = {};

  @override
  FutureOr<void> build() {
    _setupDio();
  }

  final _dio = Dio();

  void _setupDio() {
    // 基础配置
    _dio.options
      ..connectTimeout = _defaultConnectTimeout
      ..receiveTimeout = _defaultReceiveTimeout
      ..sendTimeout = _defaultSendTimeout;

    // 拦截器配置
    _dio.interceptors.addAll([
      HeaderInterceptor(
        config: const HeaderInterceptorConfig(
          connectTimeout: _defaultConnectTimeout,
          receiveTimeout: _defaultReceiveTimeout,
          sendTimeout: _defaultSendTimeout,
        ),
      ),
      CookieInterceptors(ref: ref),
      // TokenInterceptors(ref: ref),
      ErrorInterceptors(),
      ResponseInterceptors(),
      // RetryInterceptor(
      //     dio: _dio, serverErrorCode: serverErrorCode, maxRetries: _maxRetries),
      if (kDebugMode)
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
          filter: _logFilter,
        ),
    ]);
  }

  bool _logFilter(RequestOptions options, dynamic args) {
    return !args.isResponse || !args.hasUint8ListData;
  }

  /// 网络请求方法
  Future<ResultData?> netFetch(
    String url, {
    DioMethod method = DioMethod.get,
    Map<String, dynamic>? params,
    Object? data,
    Options? options,
    Map<String, dynamic>? header,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool useCache = false,
    Duration? cacheDuration,
    String? cancelToken,
    bool noTip = false,
    ResponseType? responseType = ResponseType.json,
  }) async {
    // 处理取消令牌
    if (cancelToken != null) {
      _cancelTokens[cancelToken]?.cancel('Request cancelled');
      _cancelTokens[cancelToken] = CancelToken();
    }

    final methodValues = {
      DioMethod.get: 'GET',
      DioMethod.post: 'POST',
      DioMethod.put: 'PUT',
      DioMethod.delete: 'DELETE',
      DioMethod.patch: 'PATCH',
      DioMethod.head: 'HEAD',
    };

    options ??= Options(
      method: methodValues[method],
      responseType: responseType,
    )..headers?.addAll(header ?? {});

    try {
      final response = await _dio.request(
        url,
        queryParameters: params,
        data: data,
        options: options,
        cancelToken: cancelToken != null ? _cancelTokens[cancelToken] : null,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return response.data;
    } on DioException catch (e) {
      return _handleError(e, url);
    } catch (e) {
      return ResultData(
        data: null,
        success: false,
        code: -1,
        message: e.toString(),
      );
    }
  }

  ResultData _handleError(DioException e, String url) {
    Response? errorResponse = e.response;
    errorResponse ??= Response(
      statusCode: 999,
      requestOptions: RequestOptions(path: url),
    );

    int code = errorResponse.statusCode ?? -1;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      code = -2;
    }

    return ResultData(
      data: null,
      success: false,
      code: code,
      message: e.message ?? '请求失败',
    );
  }

  /// 取消请求
  void cancelRequest(String token) {
    _cancelTokens[token]?.cancel('Request cancelled');
    _cancelTokens.remove(token);
  }
}

enum DioMethod { get, post, put, delete, patch, head }
