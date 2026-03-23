import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 用户协议页面
class UserAgreementPage extends ConsumerStatefulWidget {
  const UserAgreementPage({super.key});

  @override
  ConsumerState<UserAgreementPage> createState() => _UserAgreementPageState();
}

class _UserAgreementPageState extends ConsumerState<UserAgreementPage> {
  String _content = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  /// 加载用户协议内容
  Future<void> _loadContent() async {
    try {
      final content = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/docs/user_agreement.md');
      if (mounted) {
        setState(() {
          _content = content;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '加载失败: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('用户协议'), centerTitle: true),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadContent();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return Markdown(
      data: _content,
      padding: const EdgeInsets.all(16),
      styleSheet: MarkdownStyleSheet(
        p: Theme.of(context).textTheme.bodyLarge,
        h1: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        h2: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        h3: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        listBullet: Theme.of(context).textTheme.bodyLarge,
        blockquote: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
