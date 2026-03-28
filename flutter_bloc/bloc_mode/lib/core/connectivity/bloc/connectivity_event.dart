part of 'connectivity_bloc.dart';

/// 网络状态事件基类
sealed class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();
}

/// 启动网络监听
final class ConnectivityStarted extends ConnectivityEvent {
  const ConnectivityStarted();

  @override
  List<Object?> get props => [];
}

/// 网络状态变化（由 Service 推送）
final class ConnectivityResultChanged extends ConnectivityEvent {
  final NetworkResult networkResult;

  const ConnectivityResultChanged(this.networkResult);

  @override
  List<Object?> get props => [networkResult];
}

/// 手动重新检测网络
final class ConnectivityCheckRequested extends ConnectivityEvent {
  const ConnectivityCheckRequested();

  @override
  List<Object?> get props => [];
}

/// 停止网络监听
final class ConnectivityStopped extends ConnectivityEvent {
  const ConnectivityStopped();

  @override
  List<Object?> get props => [];
}
