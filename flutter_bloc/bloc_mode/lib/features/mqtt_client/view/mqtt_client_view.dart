import 'package:bloc_mode/core/mqtt/bloc/mqtt_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MqttClientView extends StatefulWidget {
  const MqttClientView({super.key});

  @override
  State<MqttClientView> createState() => _MqttClientViewState();
}

class _MqttClientViewState extends State<MqttClientView> {
  final List<Map<String, String>> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Client'),
      ),
      body: Column(
        children: [
          // 连接状态显示
          BlocBuilder<MqttBloc, MqttState>(
            builder: (context, state) {
              return Container(
                padding: const EdgeInsets.all(16),
                color: _getStatusColor(state),
                child: Row(
                  children: [
                    Icon(_getStatusIcon(state), color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusText(state),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          ),
          // 消息列表
          Expanded(
            child: BlocListener<MqttBloc, MqttState>(
              listener: (context, state) {
                if (state is MqttMessageReceivedState) {
                  setState(() {
                    _messages.insert(0, {
                      'topic': state.topic,
                      'payload': state.payload,
                      'timestamp': state.timestamp.toString(),
                    });
                    // 限制消息数量，避免内存溢出
                    if (_messages.length > 100) {
                      _messages.removeLast();
                    }
                  });
                }
                if (state is MqttConnectionFailed) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('MQTT连接失败')));
                }
                if (state is MqttConnected) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('MQTT连接成功')));
                  // 自动订阅测试主题
                  context
                      .read<MqttBloc>()
                      .add(const MqttSubscribeEvent(topic: 'test'));
                }
              },
              child: _buildMessageList(),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              context
                  .read<MqttBloc>()
                  .add(const MqttConnectEvent(ip: '192.168.0.4', port: 1883));
            },
            tooltip: '连接',
            child: const Icon(Icons.link),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _messages.clear();
              });
            },
            tooltip: '清空消息',
            backgroundColor: Colors.red,
            child: const Icon(Icons.clear_all),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return const Center(
        child: Text('暂无消息', style: TextStyle(fontSize: 16)),
      );
    }

    return ListView.builder(
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.message, color: Colors.blue),
            title: Text(
              message['topic']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(message['payload']!),
            trailing: Text(
              _formatTimestamp(message['timestamp']!),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  Color _getStatusColor(MqttState state) {
    if (state is MqttConnected) return Colors.green;
    if (state is MqttConnecting) return Colors.orange;
    if (state is MqttConnectionFailed) return Colors.red;
    return Colors.grey;
  }

  IconData _getStatusIcon(MqttState state) {
    if (state is MqttConnected) return Icons.check_circle;
    if (state is MqttConnecting) return Icons.sync;
    if (state is MqttConnectionFailed) return Icons.error;
    return Icons.circle_outlined;
  }

  String _getStatusText(MqttState state) {
    if (state is MqttConnecting) return '连接中...';
    if (state is MqttConnected) return '已连接到 ${state.ip}:${state.port}';
    if (state is MqttConnectionFailed) return '连接失败';
    return '未连接';
  }
}
