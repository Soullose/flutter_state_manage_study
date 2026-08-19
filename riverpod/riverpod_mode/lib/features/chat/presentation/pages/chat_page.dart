import 'package:material_ui/material_ui.dart';

import 'chat_view.dart';

/// 聊天页面入口
///
/// AppBar 使用 [Hero] 包裹图标，与首页功能卡片形成过渡动画。
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChatView();
  }

  /// Hero 过渡用的图标 shuttle builder
  static Widget flightShuttleBuilder(
    BuildContext context,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return Icon(
      Icons.chat_outlined,
      size: 24,
      color: Theme.of(fromHeroContext).colorScheme.onSurface,
    );
  }
}
