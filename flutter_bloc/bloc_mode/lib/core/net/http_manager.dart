import 'package:bloc_mode/core/net/interceptors/cookie_interceptors.dart';
import 'package:bloc_mode/core/net/interceptors/header_interceptor.dart';
import 'package:bloc_mode/core/net/result_data.dart';
import 'package:bloc_mode/core/storage/mmkv_service.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';

import '../di/injector.dart';

/// HTTP 请求管理器
///
/// 使用 Dio 进行网络请求，支持 Cookie 管理和自定义拦截器。
class HttpManager {
  // static const contentTypeJson = "application/json";
  // static const contentTypeForm = "application/x-www-form-urlencoded";

  final dio = Dio();
  final cookieJar = CookieJar();
  final MmkvDb mmkv;

  HttpManager({required this.mmkv}) {
    dio.interceptors.add(HeaderInterceptors());
    dio.interceptors.add(CookieInterceptors(mmkv: mmkv));
    dio.interceptors.add(CookieManager(cookieJar));
  }

  Future<ResultData?> netFetch(
    String url, {
    DioMethod method = DioMethod.get,
    Map<String, dynamic>? params,
    Object? data,
    Options? options,
    Map<String, dynamic>? header,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool noTip = false,
  }) async {
    const methodValues = {
      DioMethod.get: 'get',
      DioMethod.post: 'post',
      DioMethod.put: 'put',
      DioMethod.delete: 'delete',
      DioMethod.patch: 'patch',
      DioMethod.head: 'head',
      DioMethod.non: '',
    };
    if (method != DioMethod.non) {
      options ??= Options(method: methodValues[method]);
    }
    // options ??=Options(method: methodValues[method]) : null;
    if (kDebugMode) {
      print('options:$options');
    }

    Response response;

    try {
      response = await dio.request(
        url,
        queryParameters: params,
        data: data,
        options: options,
      );
      if (kDebugMode) {
        print('response:$response');
        print('responseHeaders:${response.headers}');
        print('cookie-jar:${await cookieJar.loadForRequest(Uri.parse(url))}');
      }
    } on DioException catch (e) {
      return _resultError(e, url);
    }
    if (response.data is DioException) {
      return _resultError(response.data, url);
    }

    return response.data;
  }
}

ResultData _resultError(DioException e, String url) {
  Response? errorResponse;
  if (e.response != null) {
    errorResponse = e.response;
  } else {
    errorResponse = Response(
      statusCode: 999,
      requestOptions: RequestOptions(path: url),
    );
  }
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    errorResponse!.statusCode = -2;
  }
  return ResultData(e.message, false, errorResponse!.statusCode);
}

final HttpManager httpManager = injector<HttpManager>();

enum DioMethod { get, post, put, delete, patch, head, non }
