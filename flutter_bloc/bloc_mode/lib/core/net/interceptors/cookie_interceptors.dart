import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cookie_interceptors.dart';

/// Cookie拦截器
class CookieInterceptors extends QueuedInterceptorsWrapper {
  final SharedPreferences prefs;

  CookieInterceptors({required this.prefs});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('cookie-onRequest:${options.headers}');
    }

    return handler.next(options);
  }
}
