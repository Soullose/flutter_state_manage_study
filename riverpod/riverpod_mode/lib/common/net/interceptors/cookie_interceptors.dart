import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_mode/common/storage/base/base.dart';

class CookieInterceptors extends QueuedInterceptorsWrapper {
  CookieInterceptors({required this.ref});

  final Ref ref;

  final String requestHeaderKey = 'Cookie';
  final String responseHeaderKey = 'set-cookie';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final cookie = getCookie();
    if (cookie!.isNotEmpty) {
      options.headers[requestHeaderKey] = cookie;
    }
    debugPrint('$options.headers');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    final cookie = getCookie();
    if (cookie!.isEmpty) {
      saveCookie(response);
    }
    super.onResponse(response, handler);
  }

  void saveCookie(Response<dynamic> response) async {
    final setCookie = response.headers.map[responseHeaderKey]!;
    debugPrint('cookie:$setCookie');
    ref.read(setCookieProvider(setCookie));
    // cookie = setCookie;
  }

  List<String>? getCookie() {
    final cookie = ref.read(cookieProvider).value;
    return cookie;
  }
}
