import 'package:flutter/foundation.dart';

class MqttState with ChangeNotifier {
  ///初始化Mqtt状态
  MqttAppConnectionState _appConnectionState =
      MqttAppConnectionState.disconnected;

  MqttAppConnectionState get getAppConnectionState => _appConnectionState;

  bool _connectionHealth = false;

  bool get getConnectionHealth => _connectionHealth;

  ///存放mqtt状态方法
  void setAppConnectionState(MqttAppConnectionState state) {
    if (kDebugMode) {
      print('${DateTime.now()} -$state');
    }
    _appConnectionState = state;
    notifyListeners();
  }

  void setConnectionHealth(bool health) {
    _connectionHealth = health;
    notifyListeners();
  }
}

///mqtt连接状态
enum MqttAppConnectionState {
  connected,
  connectionfailed,
  disconnected,
  connecting,
  connectedSubscribed,
  connectedUnSubscribed
}
