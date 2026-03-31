import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_mode/core/connectivity/service/connectivity_service.dart';
import 'package:bloc_mode/core/utils/app_logger.dart';
import 'package:equatable/equatable.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

/// 网络连接状态管理 Bloc
///
/// 负责监听网络状态变化并发出对应的状态
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final ConnectivityService _connectivityService;
  final _logger = AppLogger.logger;

  /// 网络服务订阅
  StreamSubscription<NetworkResult>? _networkSubscription;

  ConnectivityBloc({required ConnectivityService connectivityService})
    : _connectivityService = connectivityService,
      super(const ConnectivityInitial()) {
    // 注册事件处理器
    on<ConnectivityStarted>(_onStarted);
    on<ConnectivityResultChanged>(_onResultChanged);
    on<ConnectivityCheckRequested>(_onCheckRequested);
    on<ConnectivityStopped>(_onStopped);

    // 自动启动监听
    add(const ConnectivityStarted());
  }

  /// 处理启动事件
  Future<void> _onStarted(
    ConnectivityStarted event,
    Emitter<ConnectivityState> emit,
  ) async {
    _logger.d('ConnectivityBloc: 启动网络监听');

    // 订阅网络服务的状态流
    _networkSubscription = _connectivityService.networkResultStream.listen(
      (result) => add(ConnectivityResultChanged(result)),
      onError: (error) {
        _logger.e('ConnectivityBloc: 网络服务流错误: $error');
        emit(const ConnectivityOffline(OfflineReason.noConnection));
      },
    );

    // 启动网络服务监听
    _connectivityService.startListening();
  }

  /// 处理网络状态变化事件
  Future<void> _onResultChanged(
    ConnectivityResultChanged event,
    Emitter<ConnectivityState> emit,
  ) async {
    final result = event.networkResult;
    _logger.d('ConnectivityBloc: 网络状态变化 -> $result');

    if (result.hasInternet) {
      // 有互联网连接
      final connectionType = _mapToConnectionType(result.connectionType!);
      emit(ConnectivityOnline(connectionType));
    } else {
      // 无互联网连接，直接使用 Service 的 OfflineReason
      emit(ConnectivityOffline(result.offlineReason!));
    }
  }

  /// 处理手动检测请求
  Future<void> _onCheckRequested(
    ConnectivityCheckRequested event,
    Emitter<ConnectivityState> emit,
  ) async {
    _logger.d('ConnectivityBloc: 手动检测网络');
    emit(const ConnectivityChecking());

    final result = await _connectivityService.checkConnectivity();

    if (result.hasInternet) {
      final connectionType = _mapToConnectionType(result.connectionType!);
      emit(ConnectivityOnline(connectionType));
    } else {
      // 直接使用 Service 的 OfflineReason
      emit(ConnectivityOffline(result.offlineReason!));
    }
  }

  /// 处理停止监听事件
  Future<void> _onStopped(
    ConnectivityStopped event,
    Emitter<ConnectivityState> emit,
  ) async {
    _logger.d('ConnectivityBloc: 停止网络监听');
    await _networkSubscription?.cancel();
    _networkSubscription = null;
    _connectivityService.stopListening();
    emit(const ConnectivityInitial());
  }

  /// 将服务的 NetworkConnectionType 转换为 Bloc 的 ConnectionType
  ConnectionType _mapToConnectionType(NetworkConnectionType type) {
    switch (type) {
      case NetworkConnectionType.wifi:
        return ConnectionType.wifi;
      case NetworkConnectionType.mobile:
        return ConnectionType.mobile;
      case NetworkConnectionType.both:
        return ConnectionType.both;
    }
  }

  @override
  Future<void> close() {
    _networkSubscription?.cancel();
    _connectivityService.stopListening();
    return super.close();
  }
}
