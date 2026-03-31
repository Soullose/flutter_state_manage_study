import 'package:bloc_mode/core/storage/mmkv_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Cookie拦截器
///
/// 用于处理HTTP请求和响应中的Cookie。
class CookieInterceptors extends QueuedInterceptorsWrapper {
  final MmkvDb mmkv;

  CookieInterceptors({required this.mmkv});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('cookie-onRequest:${options.headers}');
    }

    return handler.next(options);
  }
}
