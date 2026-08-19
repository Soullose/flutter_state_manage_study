import 'package:bloc_mode/core/connectivity/bloc/connectivity_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// 网络状态提示 Banner
///
/// 根据网络状态显示不同颜色的提示条：
/// - 红色：网络连接已断开
/// - 橙色：WiFi 已连接但无法访问互联网
/// - 绿色：网络已恢复（短暂显示后消失）
///
/// 使用方式：在 MaterialApp 的 builder 中使用
/// ```dart
/// MaterialApp.router(
///   builder: (context, child) => ConnectivityBanner(child: child!),
///   routerConfig: router,
/// )
/// ```
class ConnectivityBanner extends StatefulWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  /// Banner 高度
  static const double _bannerHeight = 48.0;

  /// 动画控制器
  late AnimationController _animationController;

  /// 滑动动画
  late Animation<Offset> _slideAnimation;

  /// 当前显示的 Banner 信息
  _BannerInfo? _currentBanner;

  /// 上一次的网络状态（用于检测恢复）
  ConnectivityState? _previousState;

  /// 网络恢复提示的隐藏定时器
  bool _showingRestored = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 根据网络状态获取 Banner 信息
  _BannerInfo? _getBannerInfo(ConnectivityState state) {
    if (state is ConnectivityOffline) {
      if (state.isNoConnection) {
        return _BannerInfo(
          message: '网络连接已断开',
          icon: Icons.signal_wifi_off,
          backgroundColor: Colors.red.shade700,
        );
      } else if (state.isWifiNoInternet) {
        return _BannerInfo(
          message: 'WiFi 已连接但无法访问互联网',
          icon: Icons.wifi_lock,
          backgroundColor: Colors.orange.shade700,
        );
      }
    }
    return null;
  }

  /// 检查是否是网络恢复
  bool _isNetworkRestored(
    ConnectivityState previous,
    ConnectivityState current,
  ) {
    // 从离线变为在线
    if (previous is ConnectivityOffline && current is ConnectivityOnline) {
      return true;
    }
    return false;
  }

  /// 处理状态变化
  void _handleStateChange(ConnectivityState state) {
    final bannerInfo = _getBannerInfo(state);

    // 检查是否是网络恢复
    if (_previousState != null && _isNetworkRestored(_previousState!, state)) {
      _showRestoredBanner();
    } else if (bannerInfo != null) {
      // 显示离线 Banner
      _showBanner(bannerInfo);
    } else if (state is ConnectivityOnline) {
      // 网络正常，隐藏 Banner
      _hideBanner();
    }

    _previousState = state;
  }

  /// 显示网络恢复提示
  void _showRestoredBanner() {
    if (!mounted) return;

    setState(() {
      _showingRestored = true;
      _currentBanner = _BannerInfo(
        message: '网络已恢复',
        icon: Icons.check_circle,
        backgroundColor: Colors.green.shade600,
      );
    });

    _animationController.forward();

    // 2秒后自动隐藏
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _showingRestored) {
        _hideBanner();
      }
    });
  }

  /// 显示 Banner
  void _showBanner(_BannerInfo info) {
    if (!mounted) return;

    setState(() {
      _showingRestored = false;
      _currentBanner = info;
    });

    _animationController.forward();
  }

  /// 隐藏 Banner
  void _hideBanner() {
    if (!mounted) return;

    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _currentBanner = null;
          _showingRestored = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityBloc, ConnectivityState>(
      listener: (context, state) {
        _handleStateChange(state);
      },
      child: Stack(
        children: [
          // 主内容
          widget.child,

          // Banner（使用 Positioned 实现从顶部滑入效果）
          if (_currentBanner != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildBanner(_currentBanner!),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建 Banner Widget
  Widget _buildBanner(_BannerInfo info) {
    return Material(
      color: info.backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: _bannerHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(info.icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  info.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Banner 信息
class _BannerInfo {
  final String message;
  final IconData icon;
  final Color backgroundColor;

  _BannerInfo({
    required this.message,
    required this.icon,
    required this.backgroundColor,
  });
}
