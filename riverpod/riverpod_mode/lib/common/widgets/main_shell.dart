import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 底部导航栏 Shell 组件
///
/// 用于包裹需要显示底部导航栏的页面，如首页和我的页面
/// 子页面（如计数器、设置等）不显示底部导航栏
class MainShell extends StatelessWidget {
  /// 子页面
  final Widget child;

  const MainShell({super.key, required this.child});

  /// 需要显示底部导航栏的路由路径
  static const _showNavBarRoutes = {'/', '/profile'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Builder(
        builder: (context) {
          // 根据当前路由位置确定是否显示底部导航栏
          final location = GoRouterState.of(context).matchedLocation;

          // 只有在首页和我的页面才显示底部导航栏
          if (!_shouldShowNavBar(location)) {
            return const SizedBox.shrink();
          }

          final currentIndex = _calculateSelectedIndex(location);

          return NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => _onItemTapped(index, context),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: '首页',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: '我的',
              ),
            ],
          );
        },
      ),
    );
  }

  /// 判断是否应该显示底部导航栏
  bool _shouldShowNavBar(String location) {
    return _showNavBarRoutes.contains(location);
  }

  /// 根据路由路径计算当前选中的索引
  int _calculateSelectedIndex(String location) {
    if (location == '/profile') {
      return 1;
    }
    return 0;
  }

  /// 处理底部导航栏点击事件
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/profile');
        break;
    }
  }
}
