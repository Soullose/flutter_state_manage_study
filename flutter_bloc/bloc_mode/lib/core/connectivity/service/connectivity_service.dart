import 'dart:async';

import 'package:bloc_mode/core/utils/app_logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

/// 网络连接类型
enum NetworkConnectionType {
  /// WiFi 连接
  wifi,

  /// 移动网络连接
  mobile,

  /// WiFi 和移动网络同时连接
  both,
}

/// 网络状态结果
class NetworkResult {
  /// 是否有互联网连接
  final bool hasInternet;

  /// 连接类型（当 hasInternet 为 true 时有效）
  final NetworkConnectionType? connectionType;

  /// 离线原因（当 hasInternet 为 false 时有效）
  final OfflineReason? offlineReason;

  const NetworkResult.online(this.connectionType)
    : hasInternet = true,
      offlineReason = null;

  const NetworkResult.offline(this.offlineReason)
    : hasInternet = false,
      connectionType = null;

  /// 便捷构造函数 - 有网络
  factory NetworkResult.withInternet(NetworkConnectionType type) =>
      NetworkResult.online(type);

  /// 便捷构造函数 - 无网络（完全没有连接）
  static const NetworkResult noConnection = NetworkResult.offline(
    OfflineReason.noConnection,
  );

  /// 便捷构造函数 - WiFi 已连接但无互联网
  static const NetworkResult wifiNoInternet = NetworkResult.offline(
    OfflineReason.wifiNoInternet,
  );

  @override
  String toString() {
    if (hasInternet) {
      return 'NetworkResult.online($connectionType)';
    } else {
      return 'NetworkResult.offline($offlineReason)';
    }
  }
}

/// 离线原因
enum OfflineReason {
  /// 完全没有网络连接（WiFi 和移动网络都关闭）
  noConnection,

  /// WiFi 已连接但无法访问互联网
  wifiNoInternet,
}

/// 网络连接检测服务
///
/// 封装 connectivity_plus 和互联网可达性验证逻辑
class ConnectivityService {
  final _logger = AppLogger.logger;
  final Dio _dio;

  /// 互联网验证 URL（使用 Google 的连通性检测端点）
  static const String _connectivityCheckUrl =
      'https://connectivitycheck.gstatic.com/generate_204';

  /// 验证超时时间
  static const Duration _verificationTimeout = Duration(seconds: 5);

  ConnectivityService({Dio? dio}) : _dio = dio ?? Dio();

  /// 网络状态变化流控制器
  final StreamController<NetworkResult> _networkResultController =
      StreamController<NetworkResult>.broadcast();

  /// 网络状态变化流（供 Bloc 订阅）
  Stream<NetworkResult> get networkResultStream =>
      _networkResultController.stream;

  /// connectivity_plus 订阅
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// 是否已启动监听
  bool _isStarted = false;

  /// 启动网络状态监听
  void startListening() {
    if (_isStarted) {
      _logger.w('ConnectivityService 已经在监听中');
      return;
    }

    _isStarted = true;

    // 监听 connectivity_plus 的网络变化
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    _logger.d('ConnectivityService 已启动监听');

    // 启动时立即检测一次当前网络状态
    _checkInitialConnectivity();
  }

  /// 检测初始网络状态
  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      _logger.d('初始网络状态: $results');
      await _onConnectivityChanged(results);
    } catch (e) {
      _logger.e('检测初始网络状态失败: $e');
      // 检测失败时假设无网络
      _networkResultController.add(NetworkResult.noConnection);
    }
  }

  /// 处理 connectivity_plus 的网络变化
  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    _logger.d('网络连接变化: $results');

    // 场景 1: 完全没有连接
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      _logger.w('无网络连接');
      _networkResultController.add(NetworkResult.noConnection);
      return;
    }

    // 场景 2: 包含移动网络（移动网络通常可靠，直接判定有互联网）
    if (results.contains(ConnectivityResult.mobile)) {
      // 如果同时有 WiFi 和移动网络
      if (results.contains(ConnectivityResult.wifi)) {
        _logger.d('WiFi 和移动网络同时连接');
        _networkResultController.add(
          NetworkResult.withInternet(NetworkConnectionType.both),
        );
      } else {
        _logger.d('移动网络连接');
        _networkResultController.add(
          NetworkResult.withInternet(NetworkConnectionType.mobile),
        );
      }
      return;
    }

    // 场景 3: 仅 WiFi 连接（需要验证互联网可达性）
    if (results.contains(ConnectivityResult.wifi)) {
      _logger.d('仅 WiFi 连接，开始验证互联网可达性...');
      final hasInternet = await _verifyInternetAccess();

      if (hasInternet) {
        _logger.d('WiFi 互联网可达');
        _networkResultController.add(
          NetworkResult.withInternet(NetworkConnectionType.wifi),
        );
      } else {
        _logger.w('WiFi 已连接但无法访问互联网');
        _networkResultController.add(NetworkResult.wifiNoInternet);
      }
      return;
    }

    // 其他情况（如 ethernet, bluetooth 等）暂时视为有网络
    if (results.contains(ConnectivityResult.ethernet)) {
      _logger.d('以太网连接');
      _networkResultController.add(
        NetworkResult.withInternet(NetworkConnectionType.wifi),
      );
    }
  }

  /// 验证互联网可达性
  ///
  /// 通过发起 HTTP HEAD 请求到 Google 的连通性检测端点来验证
  Future<bool> _verifyInternetAccess() async {
    try {
      final response = await _dio.head(
        _connectivityCheckUrl,
        options: Options(
          sendTimeout: _verificationTimeout,
          receiveTimeout: _verificationTimeout,
        ),
      );

      // 204 No Content 表示成功
      // 有些服务器可能返回 200
      final isSuccess =
          response.statusCode == 204 || response.statusCode == 200;
      _logger.d('互联网验证结果: ${response.statusCode}, 成功: $isSuccess');
      return isSuccess;
    } on DioException catch (e) {
      _logger.w('互联网验证失败: ${e.type} - ${e.message}');
      return false;
    } catch (e) {
      _logger.e('互联网验证异常: $e');
      return false;
    }
  }

  /// 手动触发网络检测
  ///
  /// 可用于用户手动刷新网络状态
  Future<NetworkResult> checkConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      _logger.d('手动检测网络状态: $results');

      // 复用现有的处理逻辑
      if (results.isEmpty || results.contains(ConnectivityResult.none)) {
        return NetworkResult.noConnection;
      }

      if (results.contains(ConnectivityResult.mobile)) {
        if (results.contains(ConnectivityResult.wifi)) {
          return NetworkResult.withInternet(NetworkConnectionType.both);
        }
        return NetworkResult.withInternet(NetworkConnectionType.mobile);
      }

      if (results.contains(ConnectivityResult.wifi)) {
        final hasInternet = await _verifyInternetAccess();
        if (hasInternet) {
          return NetworkResult.withInternet(NetworkConnectionType.wifi);
        }
        return NetworkResult.wifiNoInternet;
      }

      // 默认返回无网络
      return NetworkResult.noConnection;
    } catch (e) {
      _logger.e('手动检测网络状态失败: $e');
      return NetworkResult.noConnection;
    }
  }

  /// 停止监听
  void stopListening() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _isStarted = false;
    _logger.d('ConnectivityService 已停止监听');
  }

  /// 释放资源
  void dispose() {
    stopListening();
    _networkResultController.close();
    _logger.d('ConnectivityService 已释放');
  }
}
