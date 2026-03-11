import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:bloc_mode/core/mqtt/mqtt_server_client_service.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:mqtt_client/mqtt_client.dart';

part 'mqtt_event.dart';

part 'mqtt_state.dart';

class MqttBloc extends Bloc<MqttEvent, MqttState> {
  MqttBloc() : super(MqttDisconnected()) {
    on<MqttEvent>((event, emit) {});

    /// 连接
    on<MqttConnectEvent>(_connect);

    /// 断开
    on<MqttDisconnectEvent>(_disconnect);

    /// 订阅
    on<MqttSubscribeEvent>(_subscribe);

    /// 取消订阅
    on<MqttUnsubscribeEvent>(_unsubscribe);

    /// 发布
    on<MqttPublishEvent>(_publish);

    /// 接收消息
    on<MqttMessageReceivedEvent>(_onMessageReceived);
  }

  final MqttServerClientService _mqttServerClientService =
      MqttServerClientService();

  /// 关闭
  @override
  Future<void> close() {
    _mqttServerClientService.disConnect();
    return super.close();
  }

  /// Connect to MQTT broker
  Future<void> _connect(MqttConnectEvent event, Emitter<MqttState> emit) async {
    final String ip = event.ip;
    final int port = event.port;
    emit(const MqttConnecting());

    try {
      final MqttConnectionState status = await _mqttServerClientService.connect(
        ip,
        port,
      );
      log('status: $status');
      if (status == MqttConnectionState.connected) {
        log('123');
        emit(MqttConnected(ip: ip, port: port));
        log('321');
      } else {
        emit(MqttConnectionFailed());
      }
    } catch (e) {
      emit(MqttConnectionFailed());
    }
  }

  /// Disconnect from MQTT broker
  void _disconnect(MqttDisconnectEvent event, Emitter<MqttState> emit) {
    emit(MqttDisconnected());
    _mqttServerClientService.disConnect();
  }

  /// Subscribe to a topic
  void _subscribe(MqttSubscribeEvent event, Emitter<MqttState> emit) {
    final String topic = event.topic;
    try {
      _mqttServerClientService.subScribeTo(topic, MqttQos.atLeastOnce);
      emit(MqttConnectedSubscribed());
    } catch (e) {
      emit(MqttConnectedSubscribeFailed());
    }
  }

  /// Unsubscribe from a topic
  void _unsubscribe(MqttUnsubscribeEvent event, Emitter<MqttState> emit) {
    emit(MqttConnectedSubscribeFailed());
  }

  /// Publish a message to a topic
  void _publish(MqttPublishEvent event, Emitter<MqttState> emit) {
    emit(MqttPublish(topic: event.topic, payload: event.message));
  }

  /// 处理接收到的MQTT消息
  void _onMessageReceived(
    MqttMessageReceivedEvent event,
    Emitter<MqttState> emit,
  ) {
    emit(
      MqttMessageReceivedState(
        topic: event.topic,
        payload: event.payload,
        timestamp: event.timestamp,
      ),
    );
  }
}
