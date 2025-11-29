import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_mode/core/mqtt/mqtt_server_client_service.dart';

part 'mqtt_service_provider.g.dart';

@Riverpod(keepAlive: true)
MqttServerClientService mqttServerClientService(Ref ref) {
  return MqttServerClientService();
}

/// 2. 核心：StreamProvider
///
/// 生成器会根据返回类型 Stream<Map<String, String>> 自动生成对应的 AutoDisposeStreamProvider
@riverpod
Stream<Map<String, String>> mqttMessage(Ref ref) {
  /// 监听上面的 mqttServiceProvider
  final service = ref.watch(mqttServerClientServiceProvider);
  return service.messageStream;
}
