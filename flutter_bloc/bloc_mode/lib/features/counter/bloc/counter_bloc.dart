import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:bloc_mode/core/di/injector.dart';
import 'package:bloc_mode/core/net/HttpManager.dart';
import 'package:bloc_mode/features/counter/bloc/counter_event.dart';
import 'package:bloc_mode/features/counter/bloc/counter_state.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:encrypt/encrypt.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterState.init()) {
    // on<InitCountEvent>((event, emit) => _init(event, emit));
    // on<IncrementCountEvent>((event, emit) => _increment(event, emit));
    on<InitCountEvent>(_init);
    on<IncrementCountEvent>(_increment);
  }

  void _init(InitCountEvent event, Emitter<CounterState> emit) {
    emit(CounterState.init());
  }

  _increment(IncrementCountEvent event, Emitter<CounterState> emit) async {
    // final strBytes = utf8.encode('Jzsoft@168');
    // final base64String = base64.encode(strBytes);
    // final customBase64String = CustomBase64.encode('Jzsoft@168');
    // if (kDebugMode) {
    //   print('base64:$base64String');
    //   print('base64:$customBase64String');
    // }
    // final test =
    //     'g7tIrBccubYlOamPu4yHUXTBKSOVSeLsooGEtEyBVPiMPJA+tZ2+aHH+nU7YPosxVDydH9nB5RkprRH1dKBOMvhRjs5WSbdDiT0J+LbYHfC0evyl4YztWjV5Sz2hKeYYRYl0v6fxNsgAiG3H6D3k0zNZMlXZwpEdu0AAD+qoEJg=';
    // final test1 =
    //     'jPoiJFa7Qdx95IJEwTNoO6/kCHN4G09uZAKwFr4yVF1sLPNKKr3dYkHSG0Sn43GC3j92PhhOLwspWrWa0vQ34pzrcTYyyE+aYcWjj0lmtouMwWq22mIQE2OeSuHXzh0YgAIPILTAHWgKJGkNGuSRpxJU2qY0KatyHIxgctaOjmE=';
    // String BEGIN_PUBLIC_KEY = '-----BEGIN PUBLIC KEY-----';
    // String END_PUBLIC_KEY = '-----END PUBLIC KEY-----';
    // dynamic publickey = RSAKeyParser().parse(BEGIN_PUBLIC_KEY +
    //     '\r' +
    //     'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCPpLfSzW7K7ZP1CGL6iUbOHXMtZaiRicIdiNzPDv29DdzSRRHzFhYZRa5FWI7mrIgcDha+eGHHfmoy3JPI0XwfHQ0w9mat6isasBp+ZTQhutkP2BaBGXZKYdVuOOV9TTVL45UTQAIzdJwSsBBDVCeo+xfyxt4gUxxtrdDa+iImWQIDAQAB' +
    //     '\r' +
    //     END_PUBLIC_KEY);
    //
    // final encrypter = Encrypter(RSA(publicKey: publickey));
    // Map<String, String> formData = {
    //   "language": "zh-CHS",
    //   "seType": "true",
    //   "Tenant": "10000",
    //   "Authenstrategy": "UserPassword",
    //   "username": "wsf",
    //   "password": encrypter.encrypt('Jzsoft@168').base64
    // };
    // FormData data = FormData.fromMap(formData);

    // final cookieJar = CookieJar();
    // final dio = Dio()
    //   ..interceptors.add(CookieManager(cookieJar))
    //   ..options.followRedirects = false
    //   ..options.validateStatus =
    //       (status) => status != null && status >= 200 && status < 400;
    // final redirected =
    //     await dio.post('http://47.122.113.63:5200/sign-in', data: data);
    // if (kDebugMode) {
    //   print(
    //       'cookie-jar:${await cookieJar.loadForRequest(Uri.parse('http://47.122.113.63:5200/sign-in'))}');
    //   print('redirected:${redirected.headers}');
    //   print('redirected-1:$redirected');
    // }
    // final response = await dio.get(
    //   redirected.headers.value(HttpHeaders.locationHeader)!,
    // );
    // if (kDebugMode) {
    //   print(
    //       'cookie-jar:${await cookieJar.loadForRequest(Uri.parse(redirected.headers.value(HttpHeaders.locationHeader)!))}');
    //   print('response:$response');
    // }
    // var response1 = await httpManager.netFetch(
    //   'http://47.122.113.63:5200/sign-in',
    //   method: DioMethod.post,
    //   data: data,
    // );
    // var response = httpManager.netFetch('https://www.baidu.com/');
    // if (kDebugMode) {
    //   print('headers-:${response!.headers}');
    //   print('response2222-:${response.code}');
    //   print('response1111-:${response.data}');
    // }
    // final redirected = await httpManager.netFetch(
    //   'http://47.122.113.63:5200/platform/runtime/sys/web/index.html#/ssologin',
    //   options: Options(
    //       followRedirects: false,
    //       validateStatus: (status) =>
    //           status != null && status >= 200 && status < 400),
    // );
    //
    // if (kDebugMode) {
    //   print('redirected-2222-:${redirected!.code}');
    //   print('redirected-1111-:${redirected.data}');
    //   print('ccc:${response!.headers.value(HttpHeaders.locationHeader)}');
    // }
    // final response1 = await httpManager
    //     .netFetch(response!.headers.value(HttpHeaders.locationHeader));
    //
    // if (kDebugMode) {
    //   print('response1-2222-:${response1!.code}');
    //   print('response1-1111-:${response1.data}');
    // }
    emit(CounterState.increment(state.counter + 1));
  }
}

// 自定义 Base64 编码器（等效 JS 版本）
class CustomBase64 {
  static const String _keyStr =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

  static String encode(String input) {
    final bytes = _utf8Encode(input);
    String output = '';
    int i = 0;

    while (i < bytes.length) {
      final chr1 = i < bytes.length ? bytes[i++] : 0;
      final chr2 = i < bytes.length ? bytes[i++] : 0;
      final chr3 = i < bytes.length ? bytes[i++] : 0;

      final enc1 = chr1 >> 2;
      final enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
      final enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
      final enc4 = chr3 & 63;

      String part = _keyStr[enc1] + _keyStr[enc2];
      part += (chr2 == 0 && i > bytes.length)
          ? '=='
          : (chr3 == 0 && i > bytes.length)
              ? '='
              : _keyStr[enc3] + _keyStr[enc4];

      output += part;
    }

    return output;
  }

  // UTF-8 编码（等效 JS 的 _utf8_encode）
  static List<int> _utf8Encode(String str) {
    return utf8.encode(str);
  }
}
