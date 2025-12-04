import 'package:bloc_mode/core/di/injector.dart';
import 'package:bloc_mode/core/mqtt/bloc/mqtt_bloc.dart';
import 'package:bloc_mode/core/mqtt/mqtt_server_client_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'mqtt_client_view.dart';

class MqttClientPage extends StatelessWidget {
  const MqttClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) {
        final mqttBloc = injector.get<MqttBloc>();
        // 设置MQTT服务的消息回调
        MqttServerClientService().setMessageCallback((topic, payload) {
          mqttBloc.add(MqttMessageReceivedEvent(
            topic: topic,
            payload: payload,
            timestamp: DateTime.now(),
          ));
        });
        return mqttBloc;
      },
      child: const MqttClientView(),
    );
  }
}
