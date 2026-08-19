import 'package:bloc_mode/core/di/injector.dart';
import 'package:bloc_mode/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'chat_view.dart';

/// 聊天页面
///
/// 参照 [package:bloc_mode/features/counter/view/bloc/counter_page.dart] 的结构：
/// 在页面根部用 [BlocProvider] 注入 [ChatBloc]（来自 DI 工厂），
/// 子树通过 [BlocBuilder] / [context.read] 使用。
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => injector<ChatBloc>(),
      child: const ChatView(),
    );
  }
}
