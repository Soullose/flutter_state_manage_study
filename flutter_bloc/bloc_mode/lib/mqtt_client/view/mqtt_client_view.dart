import 'dart:developer';

import 'package:bloc_mode/common/mqtt/bloc/mqtt_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MqttClientView extends StatefulWidget {
  const MqttClientView({super.key});

  @override
  State<MqttClientView> createState() => _MqttClientViewState();
}

class _MqttClientViewState extends State<MqttClientView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocListener<MqttBloc, MqttState>(
          bloc: MqttBloc(),
          listener: (context, state) {
            if (state is MqttConnectionFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mqtt connection failed')));
            }
            if (state is MqttConnected) {
              log('message');
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mqtt connection success')));
              context
                  .read<MqttBloc>()
                  .add(const MqttSubscribeEvent(topic: 'test'));
            }
          },
          child: Container(
            child: BlocBuilder<MqttBloc, MqttState>(
              builder: (context, state) {
                if (state is MqttConnecting) {
                  return const Text('Connecting...');
                }
                if (state is MqttConnected) {
                  return Text('Connected to ${state.ip}');
                }
                if (state is MqttConnectionFailed) {
                  return const Text('Connection failed');
                }
                return const Text('Disconnected');
              },
            ),
          ),
        ),
      ),
      floatingActionButton: BlocBuilder<MqttBloc, MqttState>(
        builder: (context, state) {
          return FloatingActionButton(
            onPressed: () {
              context
                  .read<MqttBloc>()
                  .add(const MqttConnectEvent(ip: '192.168.5.100', port: 1883));
            },
            tooltip: 'Connect',
            child: const Icon(Icons.adb),
          );
        },
      ),
    );
  }
}
