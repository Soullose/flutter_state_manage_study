import 'dart:async';
import 'package:flutter/foundation.dart';
import '../event/event_bus.dart';
import '../event/mqtt_events.dart';
import 'mqtt_state.dart';

/// MQTT 状态管理器 - 专门负责处理 MQTT 状态更新
class MqttStateManager {
  final EventBus _eventBus;
  final MqttState _mqttState;
  StreamSubscription? _connectionStateSubscription;
  StreamSubscription? _connectionHealthSubscription;

  MqttStateManager(this._eventBus, this._mqttState) {
    _subscribeToEvents();
  }

  /// 订阅 MQTT 相关事件
  void _subscribeToEvents() {
    // 订阅连接状态变化事件
    _connectionStateSubscription =
        _eventBus.on<MqttConnectionStateChangedEvent>().listen((event) {
      if (kDebugMode) {
        print('MqttStateManager: 收到连接状态变化事件 - ${event.state}');
      }
      _mqttState.setAppConnectionState(event.state);
    });

    // 订阅连接健康状态变化事件
    _connectionHealthSubscription =
        _eventBus.on<MqttConnectionHealthChangedEvent>().listen((event) {
      if (kDebugMode) {
        print('MqttStateManager: 收到连接健康状态变化事件 - ${event.isHealthy}');
      }
      _mqttState.setConnectionHealth(event.isHealthy);
    });
  }

  /// 释放资源
  void dispose() {
    _connectionStateSubscription?.cancel();
    _connectionHealthSubscription?.cancel();
  }
}
