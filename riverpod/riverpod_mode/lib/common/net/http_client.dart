import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_mode/common/net/result_data.dart';

import 'interceptors/error_interceptors.dart';
import 'interceptors/header_interceptor.dart';
import 'interceptors/response_interceptors.dart';

part 'http_client.g.dart';

/// 提供 Dio 实例的 Provider
@riverpod
Dio dio(Ref ref) {
  final dio = Dio();

  // 配置拦截器
  dio.interceptors.addAll([
    HeaderInterceptor(),
    ErrorInterceptors(),
    ResponseInterceptors(),
  ]);

  // 在 debug 模式下添加日志
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  return dio;
}

/// 网络请求方法
@riverpod
Future<ResultData?> netFetch(
  Ref ref, {
  required String url,
  DioMethod method = DioMethod.get,
  Map<String, dynamic>? params,
  Object? data,
  Options? options,
  Map<String, dynamic>? header,
  ProgressCallback? onSendProgress,
  ProgressCallback? onReceiveProgress,
  bool noTip = false, // 保留参数以保持兼容性
}) async {
  final dio = ref.watch(dioProvider);

  final methodValues = {
    DioMethod.get: 'GET',
    DioMethod.post: 'POST',
    DioMethod.put: 'PUT',
    DioMethod.delete: 'DELETE',
    DioMethod.patch: 'PATCH',
    DioMethod.head: 'HEAD',
  };

  options ??= Options(method: methodValues[method]);
  if (header != null) {
    options.headers ??= {};
    options.headers!.addAll(header);
  }

  try {
    final response = await dio.request(
      url,
      queryParameters: params,
      data: data,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    if (kDebugMode) {
      debugPrint('response: ${response.data}');
    }

    if (response.data is ResultData) {
      return response.data as ResultData;
    }

    return ResultData(
      data: response.data,
      success: true,
      code: response.statusCode,
    );
  } on DioException catch (e) {
    return _handleError(e, url);
  }
}

/// 处理错误
ResultData _handleError(DioException e, String url) {
  int code = e.response?.statusCode ?? -1;

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

enum DioMethod { get, post, put, delete, patch, head }
