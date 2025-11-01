part of 'mqtt_bloc.dart';

sealed class MqttEvent extends Equatable {
  const MqttEvent();
}

class MqttConnectEvent extends MqttEvent {
  const MqttConnectEvent({required this.ip, required this.port});

  final String ip;

  final int port;

  @override
  List<Object> get props => [];
}

 class MqttDisconnectEvent extends MqttEvent {
  const MqttDisconnectEvent();

  @override
  List<Object> get props => [];
}

 class MqttSubscribeEvent extends MqttEvent {
  const MqttSubscribeEvent(this.topic);

  final String topic;

  @override
  List<Object> get props => [topic];
}

 class MqttUnsubscribeEvent extends MqttEvent {
  const MqttUnsubscribeEvent(this.topic);

  final String topic;

  @override
  List<Object> get props => [topic];
}

class MqttPublishEvent extends MqttEvent {
  const MqttPublishEvent(this.topic, this.message);

  final String topic;
  final String message;

  @override
  List<Object> get props => [topic, message];
}
