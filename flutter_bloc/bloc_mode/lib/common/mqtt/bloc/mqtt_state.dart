part of 'mqtt_cubit.dart';

sealed class MqttState extends Equatable {
  const MqttState();
}

final class MqttInitial extends MqttState {
  @override
  List<Object> get props => [];
}
