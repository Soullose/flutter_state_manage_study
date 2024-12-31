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
  static const Duration _defaultConnectTimeout = Duration(seconds: 5);
  static const Duration _defaultReceiveTimeout = Duration(seconds: 3);
  static const Duration _defaultTimeout = Duration(seconds: 3);
  // static const int _maxRetries = 3;

  // 定义API错误码
  static const int successCode = 200;
  static const int authErrorCode = 401;
  static const int serverErrorCode = 400;

  // 请求配置
  // static const Map<String, String> _defaultHeaders = {
  //   'Content-Type': contentTypeJson,
  //   'Accept': contentTypeJson,
  // };

  // static const String contentTypeJson = "application/json";
  // static const String contentTypeForm = "application/x-www-form-urlencoded";

  // 取消令牌存储
  final Map<String, CancelToken> _cancelTokens = {};

  // 缓存管理
  // final Cache _cache = Cache();

  @override
  FutureOr<void> build() {
    _setupDio();
    // return null;
  }

  final _dio = Dio();

  void _setupDio() {
    // 基础配置
    _dio.options
      // ..baseUrl = 'YOUR_BASE_URL'
      ..connectTimeout = _defaultConnectTimeout
      ..receiveTimeout = _defaultReceiveTimeout
      ..sendTimeout = _defaultTimeout;
      // ..headers = _defaultHeaders;

    // 拦截器配置
    _dio.interceptors.addAll([
      HeaderInterceptors(),
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

  // 改进的网络请求方法
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
    // 检查缓存
    // if (useCache) {
    //   final cachedData = await _cache.get(url);
    //   if (cachedData != null) return cachedData;
    // }

    // 处理取消令牌
    if (cancelToken != null) {
      _cancelTokens[cancelToken]?.cancel('Request cancelled');
      _cancelTokens[cancelToken] = CancelToken();
    }

    final methodValues = {
      DioMethod.get: 'get',
      DioMethod.post: 'post',
      DioMethod.put: 'put',
      DioMethod.delete: 'delete',
      DioMethod.patch: 'patch',
      DioMethod.head: 'head'
    };

    options ??=
        Options(method: methodValues[method], responseType: responseType)
          ..headers?.addAll(header ?? {});

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

      // // 存储缓存
      // if (useCache && response.statusCode == successCode) {
      //   await _cache.set(url, resultData, duration: _cacheDuration);
      // }

      return response.data;
    } on DioException catch (e) {
      return _handleError(e, url);
    } catch (e) {
      return ResultData(e.toString(), false, -1);
    }
  }

  ResultData _handleResponse(Response response) {
    if (response.statusCode == successCode) {
      return ResultData(response.data, true, successCode);
    }
    return ResultData(response.data, false, response.statusCode ?? -1);
  }

  ResultData _handleError(DioException e, String url) {
    Response? errorResponse = e.response;
    errorResponse ??= Response(
      statusCode: 999,
      requestOptions: RequestOptions(path: url),
    );

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      errorResponse.statusCode = -2;
    }

    return ResultData(e.message, false, errorResponse.statusCode ?? -1);
  }

  // 取消请求
  void cancelRequest(String token) {
    _cancelTokens[token]?.cancel('Request cancelled');
    _cancelTokens.remove(token);
  }

// 清除所有缓存
// Future<void> clearCache() => _cache.clear();

// 清除特定URL的缓存
// Future<void> removeCacheForUrl(String url) => _cache.remove(url);
}

// 简单的缓存实现
// class Cache {
//   final Map<String, _CacheItem> _cache = {};
//
//   Future<ResultData?> get(String key) async {
//     final item = _cache[key];
//     if (item != null && !item.isExpired) {
//       return item.data;
//     }
//     _cache.remove(key);
//     return null;
//   }
//
//   Future<void> set(
//     String key,
//     ResultData value, {
//     Duration duration = const Duration(minutes: 5),
//   }) async {
//     _cache[key] = _CacheItem(
//       data: value,
//       expiryTime: DateTime.now().add(duration),
//     );
//   }
//
//   Future<void> remove(String key) async => _cache.remove(key);
//
//   Future<void> clear() async => _cache.clear();
// }

// class _CacheItem {
//   final ResultData data;
//   final DateTime expiryTime;
//
//   _CacheItem({
//     required this.data,
//     required this.expiryTime,
//   });
//
//   bool get isExpired => DateTime.now().isAfter(expiryTime);
// }

enum DioMethod {
  get,
  post,
  put,
  delete,
  patch,
  head,
}
