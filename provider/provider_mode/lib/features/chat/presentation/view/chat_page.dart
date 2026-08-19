import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:provider_mode/di/injector.dart';
import 'package:provider_mode/features/chat/presentation/view/chat_view.dart';
import 'package:provider_mode/features/chat/presentation/viewmodels/chat_view_model.dart';

/// 聊天页面
///
/// 参照 [LoginPage] 的结构：在页面根部用 [ChangeNotifierProvider.value]
/// 注入 [ChatViewModel]，子树通过 [Consumer] / [context.read] 使用。
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: injector<ChatViewModel>(),
      child: const ChatView(),
    );
  }
}
