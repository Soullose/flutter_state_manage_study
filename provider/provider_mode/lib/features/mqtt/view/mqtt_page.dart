import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:provider_mode/core/mqtt/mqtt_state.dart';

/// MQTT 状态可视化页面
///
/// 展示如何使用 Provider 监听 MQTT 连接状态变化
class MqttPage extends StatefulWidget {
  const MqttPage({super.key});

  @override
  State<MqttPage> createState() => _MqttPageState();
}

class _MqttPageState extends State<MqttPage> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // 定时刷新页面（因为 MqttState 变化时 notifyListeners 已触发）
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT 状态'),
        centerTitle: true,
      ),
      body: Consumer<MqttState>(
        builder: (context, mqttState, _) {
          final connectionState = mqttState.getAppConnectionState;
          final isHealthy = mqttState.getConnectionHealth;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 连接状态卡片
              _buildConnectionStatusCard(
                context,
                connectionState: connectionState,
                isHealthy: isHealthy,
              ),
              const SizedBox(height: 16),

              // 状态说明
              _buildInfoCard(context),
            ],
          );
        },
      ),
    );
  }

  /// 连接状态卡片
  Widget _buildConnectionStatusCard(
    BuildContext context, {
    required MqttAppConnectionState connectionState,
    required bool isHealthy,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 状态图标
            Icon(
              _getStatusIcon(connectionState),
              size: 56,
              color: _getStatusColor(connectionState, theme),
            ),
            const SizedBox(height: 12),

            // 状态文本
            Text(
              _getStatusText(connectionState),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getStatusColor(connectionState, theme),
              ),
            ),
            const SizedBox(height: 8),

            // 连接健康指示器
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isHealthy ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isHealthy ? '心跳正常' : '心跳异常',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 详细状态列表
            _buildStatusRow(
              '连接状态',
              connectionState.name,
              _getStatusColor(connectionState, theme),
            ),
            _buildStatusRow(
              '心跳状态',
              isHealthy ? '正常' : '超时',
              isHealthy ? Colors.green : Colors.red,
            ),
            _buildStatusRow(
              '更新时间',
              DateTime.now().toString().substring(11, 19),
              theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  /// 状态行
  Widget _buildStatusRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: valueColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// 说明卡片
  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'MQTT 连接说明',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '• MQTT 服务与状态管理已通过 EventBus 解耦\n'
              '• MqttServerClientService 负责网络通信\n'
              '• MqttStateManager 监听事件并更新状态\n'
              '• MqttState 通过 Provider 通知 UI 更新\n'
              '• 连接状态枚举: connected / connecting / disconnected / connectionfailed',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Provider 学习要点',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '• MqttState 注册为全局 LazySingleton + ChangeNotifier\n'
              '• UI 通过 Consumer<MqttState> 监听状态变化\n'
              '• 状态变化时自动 rebuild 相关 Widget\n'
              '• 支持多个 Widget 同时监听同一状态',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== 辅助方法 ==========

  IconData _getStatusIcon(MqttAppConnectionState state) {
    return switch (state) {
      MqttAppConnectionState.connected => Icons.cloud_done,
      MqttAppConnectionState.connecting => Icons.sync,
      MqttAppConnectionState.disconnected => Icons.cloud_off,
      MqttAppConnectionState.connectionfailed => Icons.error_outline,
      MqttAppConnectionState.connectedSubscribed => Icons.cloud_done,
      MqttAppConnectionState.connectedUnSubscribed => Icons.cloud_queue,
    };
  }

  Color _getStatusColor(MqttAppConnectionState state, ThemeData theme) {
    return switch (state) {
      MqttAppConnectionState.connected => Colors.green,
      MqttAppConnectionState.connecting => Colors.orange,
      MqttAppConnectionState.disconnected => Colors.grey,
      MqttAppConnectionState.connectionfailed => Colors.red,
      MqttAppConnectionState.connectedSubscribed => Colors.green,
      MqttAppConnectionState.connectedUnSubscribed => Colors.blue,
    };
  }

  String _getStatusText(MqttAppConnectionState state) {
    return switch (state) {
      MqttAppConnectionState.connected => '已连接',
      MqttAppConnectionState.connecting => '连接中...',
      MqttAppConnectionState.disconnected => '未连接',
      MqttAppConnectionState.connectionfailed => '连接失败',
      MqttAppConnectionState.connectedSubscribed => '已连接并订阅',
      MqttAppConnectionState.connectedUnSubscribed => '已连接未订阅',
    };
  }
}
