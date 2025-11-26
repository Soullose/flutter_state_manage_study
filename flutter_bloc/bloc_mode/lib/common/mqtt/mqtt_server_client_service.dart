import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

class MqttServerClientService {
  /// 单例实例
  static MqttServerClientService? _instance;

  /// 消息回调函数
  Function(String topic, String payload)? _onMessageReceived;

  /// 私有构造函数
  MqttServerClientService._internal();

  /// 工厂构造函数 - 单例入口点
  factory MqttServerClientService() {
    _instance ??= MqttServerClientService._internal();
    return _instance!;
  }

  /// 获取实例的静态方法（可选）
  static MqttServerClientService get instance {
    if (_instance == null) {
      throw Exception(
          'MqttServerClientService not initialized. Call factory constructor first.');
    }
    return _instance!;
  }

  /// 设置消息接收回调
  void setMessageCallback(Function(String topic, String payload) callback) {
    _onMessageReceived = callback;
  }

  /// 添加心跳监控相关变量
  DateTime? _lastPongTime;
  Timer? _heartbeatTimer;
  static const int _heartbeatTimeout = 30000;

  /// 30秒超时

  /// MQTT client instance
  late final MqttServerClient _client;
  final _uuid = const Uuid();

  Future<MqttConnectionState> connect(String server, int port) async {
    _client = MqttServerClient(server, _uuid.v4());
    _client.port = port;

    /// 设置正确的MQTT协议以测试mosquitto
    _client.setProtocolV311();

    /// 如果您打算使用保持连接，必须在此设置，否则保持连接将被禁用。
    _client.keepAlivePeriod = 5;

    /// 如果需要，可以设置连接超时期限，默认为5秒。
    _client.connectTimeoutPeriod = 2000; // 毫秒

    /// 设置自动重连
    _client.autoReconnect = true;

    /// 添加自动重连回调。
    /// 这是'预'自动重连回调，在序列开始前调用。
    _client.resubscribeOnAutoReconnect = false;

    /// 添加自动重连回调。
    /// 这是'预'自动重连回调，在序列开始前调用。
    _client.onAutoReconnect = onAutoReconnect;

    /// 添加自动重连回调。
    /// 这是'后'自动重连回调，在序列完成后调用。
    /// 请注意，当此回调被调用时，可能正在重新订阅。请参阅上面的 [resubscribeOnAutoReconnect]。
    _client.onAutoReconnected = onAutoReconnected;

    /// 如果需要，添加成功连接回调。
    /// 这将在 [onAutoReconnect] 之后但在 [onAutoReconnected] 之前调用。
    _client.onConnected = onConnected;

    /// 添加订阅回调，如果需要，还有取消订阅回调。
    /// 您可以在连接前添加这些回调，或在连接后动态更改它们。
    /// 还有一个用于订阅失败的回调onSubscribeFail，订阅失败可能是因为您尝试订阅无效主题
    /// 或代理拒绝订阅请求。
    _client.onSubscribed = onSubscribed;

    /// 如果需要，设置一个ping接收回调，每当从代理接收到ping响应（pong）时调用。
    _client.pongCallback = pong;

    /// 创建一个连接消息使用或使用默认消息。默认消息设置
    /// 客户端标识符、任何提供的用户名/密码和清除会话，
    /// 下面是一个特定消息的示例。
    final connMess = MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId')
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    if (kDebugMode) {
      print('示例::Mosquitto客户端连接中....');
    }
    _client.connectionMessage = connMess;

    /// 连接客户端，此处的任何错误都会通过引发适当的异常来传递。注意
    /// 在某些情况下，代理只会断开我们，请参阅规范关于此点的说明，但我们
    /// 永远不会发送格式错误的消息。
    try {
      await _client.connect('mqtt_vhost:mqtt', '123');
    } on Exception catch (e) {
      if (kDebugMode) {
        print('示例::客户端异常 - $e');
      }
      _client.disconnect();
      return _client.connectionStatus!.state;
    }

    /// 检查我们是否已连接
    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      if (kDebugMode) {
        print('示例::Mosquitto客户端已连接');
      }
    } else {
      /// 如果您还想要代理返回代码，请在此处使用状态而不是连接状态。
      if (kDebugMode) {
        print(
          '示例::错误 Mosquitto客户端连接失败 - 正在断开连接，状态为 ${_client.connectionStatus}',
        );
      }
      _client.disconnect();
      exit(-1);
    }
    return _client.connectionStatus!.state;
  }

  ///批量订阅主题
  void multipleSubScribe(List<BatchSubscription> subscriptions) {
    _client.subscribeBatch(subscriptions);
    _client.updates!.listen((messageList) {
      for (var recMess in messageList) {
        final pubMess = recMess.payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          pubMess.payload.message,
        );
        final topic = recMess.topic;

        if (kDebugMode) {
          print(
            'EXAMPLE::Change notification:: topic is <$topic>, payload is <-- $payload -->',
          );
        }

        // 触发消息回调
        if (_onMessageReceived != null) {
          _onMessageReceived!(topic, payload);
        }
      }
    });
  }

  ///mqtt监听 wms/scheduler/devices/%s/state
  ///         wms/scheduler/devices/message
  /// 订阅单个主题
  void subScribeTo(String topic, MqttQos? qos) {
    // _topic = topic;
    qos ??= MqttQos.atLeastOnce;
    _client.subscribe(topic, qos);
    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      for (var element in c) {
        final recMess = element.payload as MqttPublishMessage;
        final payload = const Utf8Decoder().convert(recMess.payload.message);
        final topic = element.topic;

        if (kDebugMode) {
          print('示例::接收到主题为 <$topic> 的消息,消息内容为:$payload');
        }

        // 触发消息回调
        if (_onMessageReceived != null) {
          _onMessageReceived!(topic, payload);
        }
      }
    });
  }

  void disConnect() {
    _client.disconnect();
  }

  /// 订阅回调
  void onSubscribed(String topic) {
    if (kDebugMode) {
      print('示例::主题 $topic 的订阅已确认');
    }
  }

  /// 预自动重连回调
  void onAutoReconnect() {
    if (kDebugMode) {
      print(
        '示例::onAutoReconnect 客户端回调 - 客户端自动重连序列将启动',
      );
    }
  }

  /// 后自动重连回调
  void onAutoReconnected() {
    if (kDebugMode) {
      print(
        '示例::onAutoReconnected 客户端回调 - 客户端自动重连序列已完成',
      );
    }
  }

  /// The successful connect callback
  void onConnected() {
    if (kDebugMode) {
      print(
        '示例::OnConnected 客户端回调 - 客户端连接成功',
      );
    }
  }

  /// Pong callback
  void pong() {
    try {
      if (kDebugMode) {
        print(
          '示例::Ping 响应客户端回调被调用 - 您可能想在此处断开您的代理',
        );
      }

      /// 1. 记录心跳
      _lastPongTime = DateTime.now();

      /// 2. 更新连接健康状态

      /// 重置心跳检查定时器
      _startHeartbeatMonitor();
    } catch (e) {
      if (kDebugMode) {
        print('MQTT::pong回调处理异常: $e');
      }
    }
  }

  /// 启动心跳监控
  void _startHeartbeatMonitor() {
    _heartbeatTimer?.cancel();

    _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkHeartbeat();
    });
  }

  void _checkHeartbeat() {
    if (_lastPongTime == null) return;

    final now = DateTime.now();
    final difference = now.difference(_lastPongTime!).inMilliseconds;

    if (difference > _heartbeatTimeout) {
      if (kDebugMode) {
        print('MQTT::心跳超时 - 最后响应: ${difference}ms 前');
      }

      /// 可选：触发重连逻辑
      _handleHeartbeatTimeout();
    }
  }

  /// 处理心跳超时
  void _handleHeartbeatTimeout() {
    if (kDebugMode) {
      print('MQTT::心跳超时，尝试重新连接...');
    }

    /// 停止当前监控
    _heartbeatTimer?.cancel();

    /// 触发重连逻辑
    if (_client.connectionStatus?.state != MqttConnectionState.connected) {
      // _reconnect();
    }
  }
}
