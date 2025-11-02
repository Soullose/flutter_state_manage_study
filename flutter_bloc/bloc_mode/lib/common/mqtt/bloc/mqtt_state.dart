part of 'mqtt_bloc.dart';

@immutable
sealed class MqttState extends Equatable {
  const MqttState();
}

/// mqtt连接成功
final class MqttConnected extends MqttState {
  const MqttConnected({required this.ip, required this.port});

  final String ip;

  final int port;

  @override
  List<Object> get props => [ip, port];
}

/// mqtt连接失败
final class MqttConnectionFailed extends MqttState {
  @override
  List<Object> get props => [];
}

/// mqtt连接中
final class MqttConnecting extends MqttState {
  const MqttConnecting();

  @override
  List<Object> get props => [];
}

/// mqtt断开连接
final class MqttDisconnected extends MqttState {
  @override
  List<Object> get props => [];
}

/// mqtt连接成功订阅成功
final class MqttConnectedSubscribed extends MqttState {
  @override
  List<Object> get props => [];
}

/// mqtt连接成功订阅失败
final class MqttConnectedSubscribeFailed extends MqttState {
  @override
  List<Object> get props => [];
}

/// mqtt发布消息
final class MqttPublish extends MqttState {
  const MqttPublish({required this.topic, required this.payload});

  final String topic;

  final String payload;

  @override
  List<Object> get props => [topic, payload];
}
