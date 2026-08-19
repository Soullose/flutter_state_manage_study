import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:provider_mode/di/injector.dart';
import 'package:provider_mode/features/auth/presentation/viewmodels/auth_view_model.dart';

/// 登录页面
///
/// 展示 Provider 在表单场景中的使用：
/// - Consumer 监听加载/错误状态
/// - context.read 调用业务方法
/// - 表单验证与错误处理
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'test@example.com');
  final _passwordController = TextEditingController(text: '123456');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: injector<AuthViewModel>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Provider认证示例'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),

                  // 认证图标
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mock 登录',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Consumer<AuthViewModel>(
                    builder: (context, vm, _) {
                      if (vm.isAuthenticated) {
                        return _buildAuthenticatedCard(context);
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 32),

                  // 邮箱输入框
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: '邮箱',
                      hintText: 'test@example.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入邮箱';
                      }
                      if (!value.contains('@')) {
                        return '邮箱格式不正确';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 密码输入框
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: '密码',
                      hintText: '123456',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入密码';
                      }
                      if (value.length < 6) {
                        return '密码长度不能少于6位';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 错误提示
                  Consumer<AuthViewModel>(
                    builder: (context, vm, _) {
                      if (vm.errorMessage == null) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  vm.errorMessage!,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // 登录按钮
                  Consumer<AuthViewModel>(
                    builder: (context, vm, _) {
                      return SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: vm.isLoading ? null : () => _handleLogin(),
                          child: vm.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('登录',
                                  style: TextStyle(fontSize: 16)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 提示信息
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Mock 测试账号',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '邮箱: test@example.com\n密码: 123456\n\n'
                            '也可输入 admin@example.com / admin123',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 已认证状态卡片
  Widget _buildAuthenticatedCard(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        final user = vm.currentUser;
        if (user == null) return const SizedBox.shrink();

        return Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '欢迎, ${user.name}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: vm.isLoading
                      ? null
                      : () => context.read<AuthViewModel>().logout(),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('登出'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 处理登录
  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    context.read<AuthViewModel>().login(email, password);
  }
}
