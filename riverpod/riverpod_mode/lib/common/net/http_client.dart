import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_mode/common/net/result_data.dart';

import 'interceptors/cookie_interceptors.dart';
import 'interceptors/error_interceptors.dart';
import 'interceptors/header_interceptor.dart';
import 'interceptors/response_interceptors.dart';
import 'interceptors/token_interceptors.dart';

part 'http_client.g.dart';

const contentTypeJson = "application/json";
const contentTypeForm = "application/x-www-form-urlencoded";

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
  noTip = false,
}) async {
  const methodValues = {
    DioMethod.get: 'get',
    DioMethod.post: 'post',
    DioMethod.put: 'put',
    DioMethod.delete: 'delete',
    DioMethod.patch: 'patch',
    DioMethod.head: 'head'
  };

  final dio = Dio();
  dio.interceptors.add(HeaderInterceptors());
  dio.interceptors.add(CookieInterceptors(ref: ref));
  dio.interceptors.add(TokenInterceptors(ref: ref));
  dio.interceptors.add(ErrorInterceptors());
  dio.interceptors.add(ResponseInterceptors());

  options ??= Options(method: methodValues[method]);
  // print(options.headers);

  resultError(DioException e) {
    Response? errorResponse;
    if (e.response != null) {
      errorResponse = e.response;
    } else {
      errorResponse =
          Response(statusCode: 999, requestOptions: RequestOptions(path: url));
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      errorResponse!.statusCode = -2;
    }
    return ResultData(e.message, false, errorResponse!.statusCode);
  }

  Response response;

  try {
    response = await dio.request(url,
        queryParameters: params, data: data, options: options);
    if (response.data is DioException) {
      return resultError(response.data);
    }
    return response.data;
  } on DioException catch (e) {
    return resultError(e);
  }
}

enum DioMethod {
  get,
  post,
  put,
  delete,
  patch,
  head,
}
