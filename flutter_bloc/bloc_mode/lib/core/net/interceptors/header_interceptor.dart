import 'package:dio/dio.dart';

/// header拦截器
/// Created by guoshuyu
/// on 2019/3/23.
class HeaderInterceptors extends InterceptorsWrapper {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    ///超时
    options.connectTimeout = const Duration(seconds: 3);
    options.receiveTimeout = const Duration(seconds: 3);
    options.followRedirects = false;
    options.validateStatus =
        (status) => status != null && status >= 200 && status < 400;

    super.onRequest(options, handler);
  }
}
