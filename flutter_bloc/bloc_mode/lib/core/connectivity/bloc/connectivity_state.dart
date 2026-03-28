part of 'connectivity_bloc.dart';

/// 网络连接类型
enum ConnectionType {
  /// WiFi 连接
  wifi,

  /// 移动网络连接
  mobile,

  /// WiFi 和移动网络同时连接
  both,
}

/// 网络状态基类
sealed class ConnectivityState extends Equatable {
  const ConnectivityState();
}

/// 初始状态
final class ConnectivityInitial extends ConnectivityState {
  const ConnectivityInitial();

  @override
  List<Object?> get props => [];
}

/// 网络检测中
final class ConnectivityChecking extends ConnectivityState {
  const ConnectivityChecking();

  @override
  List<Object?> get props => [];
}

/// 网络可用状态
final class ConnectivityOnline extends ConnectivityState {
  /// 连接类型
  final ConnectionType connectionType;

  const ConnectivityOnline(this.connectionType);

  /// 是否是 WiFi 连接
  bool get isWifi =>
      connectionType == ConnectionType.wifi ||
      connectionType == ConnectionType.both;

  /// 是否是移动网络连接
  bool get isMobile =>
      connectionType == ConnectionType.mobile ||
      connectionType == ConnectionType.both;

  @override
  List<Object?> get props => [connectionType];
}

/// 网络不可用状态
/// 使用 ConnectivityService 中定义的 OfflineReason
final class ConnectivityOffline extends ConnectivityState {
  /// 离线原因（来自 ConnectivityService）
  final OfflineReason reason;

  const ConnectivityOffline(this.reason);

  /// 是否是完全无连接
  bool get isNoConnection => reason == OfflineReason.noConnection;

  /// 是否是 WiFi 无互联网
  bool get isWifiNoInternet => reason == OfflineReason.wifiNoInternet;

  @override
  List<Object?> get props => [reason];
}
