import 'package:provider_mode/core/mqtt/mqtt_state.dart';

/// MQTT 连接状态变化事件
class MqttConnectionStateChangedEvent {
  final MqttAppConnectionState state;
  MqttConnectionStateChangedEvent(this.state);
}

/// MQTT 连接健康状态变化事件
class MqttConnectionHealthChangedEvent {
  final bool isHealthy;
  MqttConnectionHealthChangedEvent(this.isHealthy);
}

/// MQTT 消息接收事件
class MqttMessageReceivedEvent {
  final String topic;
  final String payload;
  MqttMessageReceivedEvent(this.topic, this.payload);
}
