import 'dart:async';

/// 事件总线 - 用于组件间的解耦通信
class EventBus {
  final _controller = StreamController<dynamic>.broadcast();

  /// 订阅指定类型的事件
  Stream<T> on<T>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  /// 发布事件
  void fire(dynamic event) {
    _controller.add(event);
  }

  /// 释放资源
  void dispose() {
    _controller.close();
  }
}
