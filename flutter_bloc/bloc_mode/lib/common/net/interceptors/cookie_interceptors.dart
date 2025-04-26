import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CookieInterceptors extends QueuedInterceptorsWrapper {
  CookieInterceptors({required this.prefs});

  final SharedPreferences prefs;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {}

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
//
  }
}
