import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_mode/core/mqtt/mqtt_server_client_service.dart';
import 'package:provider_mode/core/mqtt/mqtt_state.dart';
import 'package:provider_mode/di/injector.dart';

import '../counter_provider.dart';

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    final MqttServerClientService mqttClientService =
        injector<MqttServerClientService>();
    // 移除直接注入的MqttState实例，统一使用Provider监听
    mqttStateToast(
        context.watch<MqttState>().getAppConnectionState, mqttClientService);
    return Scaffold(
      appBar: AppBar(title: const Text('学习Provider状态管理'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:'),
            // Count(),
            Text(
              /// Calls `context.watch` to make [Count] rebuild when [Counter] changes.
              '${context.watch<CounterProvider>().count}',
              key: const Key('counterState'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              /// Calls `context.watch` to make [Count] rebuild when [Counter] changes.
              '${context.watch<MqttState>().getAppConnectionState}',
              key: Key('counterState1'),
              style: Theme.of(context).textTheme.headlineMedium,
            )
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   key: const Key('increment_floatingActionButton'),
      //   onPressed: () => context.read<CounterProvider>().increment(),
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),

      floatingActionButton: FloatingActionButton(
        key: const Key('mqttClientService_floatingActionButton'),
        onPressed: () {
          mqttClientService.connect('192.168.5.47', 1883);
        },
        tooltip: 'mqttClientService',
        child: const Icon(Icons.multiple_stop),
      ),
    );
  }

  ///根据mqtt状态提示信息
  void mqttStateToast(
      MqttAppConnectionState state, MqttServerClientService mqttClientService) {
    if (kDebugMode) {
      print('mqttState - $state');
    }
    if (state == MqttAppConnectionState.connected) {
      if (kDebugMode) {
        print('mqtt已连接');
      }
      mqttClientService.subScribeTo('topic1', null);
      mqttClientService.subScribeTo('topic2', null);
    }
  }
}

class Count extends StatelessWidget {
  const Count({super.key});

  @override
  Widget build(BuildContext context) {
    // final count = Provider.of<CounterProvider>(context);
    return Text(
      /// Calls `context.watch` to make [Count] rebuild when [Counter] changes.
      '${context.watch<CounterProvider>().count}',
      key: const Key('counterState'),
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}
