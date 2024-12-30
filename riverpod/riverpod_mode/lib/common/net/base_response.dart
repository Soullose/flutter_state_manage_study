import 'package:json_annotation/json_annotation.dart';

part 'base_response.g.dart';

/// Data是对象
@JsonSerializable(genericArgumentFactories: true)
class DataResponse<T> {
  final T? data;
  final int errorCode;
  final String errorMsg;

  DataResponse({required this.data, required this.errorCode, required this.errorMsg});

  factory DataResponse.fromJson(Map<String, dynamic> json, T Function(dynamic json) fromJsonT) =>
      _$DataResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(dynamic Function(T value) toJsonT) => _$DataResponseToJson(this, toJsonT);
}

/// Data是列表
@JsonSerializable(genericArgumentFactories: true)
class ListResponse<T> {
  final List<T>? data;
  final int errorCode;
  final String errorMsg;

  ListResponse({required this.data, required this.errorCode, required this.errorMsg});

  factory ListResponse.fromJson(Map<String, dynamic> json, T Function(dynamic json) fromJsonT) =>
      _$ListResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(dynamic Function(T value) toJsonT) => _$ListResponseToJson(this, toJsonT);
}

/// 解析列表
List<T> parseList<T>(dynamic json, T Function(Map<String, dynamic>) fromJson) =>
    (json as List).map((e) => fromJson(e)).toList();