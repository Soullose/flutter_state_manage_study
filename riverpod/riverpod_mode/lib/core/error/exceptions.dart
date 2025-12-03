// lib/core/error/exceptions.dart

/// 1. 服务器异常：当网络请求失败、超时或返回 HTTP 400/500 状态码时抛出
class ServerException implements Exception {
  final int? statusCode;
  final String? message;

  /// 允许携带 HTTP 状态码和错误信息
  const ServerException({this.statusCode, this.message});
}

/// 2. 缓存/本地数据异常：当从本地数据库或缓存中读取/写入数据失败时抛出
class CacheException implements Exception {
  final String? message;

  const CacheException({this.message});
}

/// 3. 认证异常：通常在 API 客户端（Data Source）接收到 401 Unauthorized 状态码时抛出
class AuthenticationException implements Exception {
  final String? message;

  const AuthenticationException({this.message});
}
