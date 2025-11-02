import 'package:bloc_mode/common/mqtt/bloc/mqtt_bloc.dart';
import 'package:bloc_mode/counter/bloc/counter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'mqtt_client_view.dart';

class MqttClientPage extends StatelessWidget {
  const MqttClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => CounterBloc(),
      child: MqttClientView(),
    );
  }
}
