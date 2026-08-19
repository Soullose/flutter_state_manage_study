import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_mode/features/setting/riverpod/setting.dart';

class SettingView extends ConsumerWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingState = ref.read(settingProvider.notifier);
    final setting = ref.watch(settingProvider);
    if (kDebugMode) {
      print('setting---:$setting');
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'hero_/riverpodSetting',
              flightShuttleBuilder: _flightShuttleBuilder,
              child: const Icon(Icons.settings_outlined),
            ),
            const SizedBox(width: 8),
            const Text('Setting example'),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 网络设置分组
            _buildSectionHeader(context, '网络设置'),
            _buildSettingCard(
              context,
              children: [
                _SettingsTile(
                  icon: Icons.dns_outlined,
                  title: '服务地址',
                  value: setting.value?.ipAddress ?? '未设置',
                  onTap: () => _showEditBottomSheet(
                    context,
                    title: '编辑服务地址',
                    hintText: '请输入IP地址',
                    initialValue: setting.value?.ipAddress ?? '',
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    onSaved: (value) async {
                      if (value != null && value.isNotEmpty) {
                        await settingState.setIpAddress(value);
                      }
                    },
                  ),
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.language_outlined,
                  title: '端口号',
                  value: '8080',
                  onTap: () => _showEditBottomSheet(
                    context,
                    title: '编辑端口号',
                    hintText: '请输入端口号',
                    initialValue: '8080',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSaved: (value) {
                      // 保存端口号逻辑
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // AI 服务设置分组
            _buildSectionHeader(context, 'AI 服务'),
            _buildSettingCard(
              context,
              children: [
                _SettingsTile(
                  icon: Icons.cloud_outlined,
                  title: '接口地址',
                  value: setting.value?.apiBaseUrl ?? '未设置',
                  onTap: () => _showEditBottomSheet(
                    context,
                    title: '编辑接口地址',
                    hintText: '请输入接口地址（如 https://api.openai.com）',
                    initialValue: setting.value?.apiBaseUrl ?? '',
                    onSaved: (value) async {
                      if (value != null && value.isNotEmpty) {
                        await settingState.setApiBaseUrl(value);
                      }
                    },
                  ),
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.key_outlined,
                  title: 'API Key',
                  value: _maskApiKey(setting.value?.apiKey ?? ''),
                  onTap: () => _showEditBottomSheet(
                    context,
                    title: '编辑 API Key',
                    hintText: '请输入 API Key',
                    initialValue: setting.value?.apiKey ?? '',
                    onSaved: (value) async {
                      if (value != null) {
                        await settingState.setApiKey(value);
                      }
                    },
                  ),
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.model_training_outlined,
                  title: '模型名称',
                  value: setting.value?.apiModel ?? '未设置',
                  onTap: () => _showEditBottomSheet(
                    context,
                    title: '编辑模型名称',
                    hintText: '请输入模型名称（如 gpt-3.5-turbo）',
                    initialValue: setting.value?.apiModel ?? '',
                    onSaved: (value) async {
                      if (value != null && value.isNotEmpty) {
                        await settingState.setApiModel(value);
                      }
                    },
                  ),
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.science_outlined,
                  title: '使用模拟数据',
                  value: (setting.value?.useMock ?? true) ? '开启' : '关闭',
                  showArrow: false,
                  onTap: () => _showMockToggleSheet(
                    context,
                    currentValue: setting.value?.useMock ?? true,
                    onChanged: (value) async {
                      await settingState.setUseMock(value);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 其他设置分组
            _buildSectionHeader(context, '其他'),
            _buildSettingCard(
              context,
              children: [
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: '关于',
                  value: 'v1.0.0',
                  showArrow: false,
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Riverpod Mode',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2026 Riverpod Study',
                      children: [
                        const SizedBox(height: 16),
                        const Text('一个用于学习 Riverpod 状态管理的示例应用。'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  /// 隐藏 API Key 中间部分，只显示首尾
  String _maskApiKey(String apiKey) {
    if (apiKey.isEmpty) return '未设置';
    if (apiKey.length <= 8) return '••••';
    return '${apiKey.substring(0, 4)}••••${apiKey.substring(apiKey.length - 4)}';
  }

  /// 显示数据源切换弹窗（模拟 / 真实接口）
  void _showMockToggleSheet(
    BuildContext context, {
    required bool currentValue,
    required ValueChanged<bool> onChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MockToggleSheet(
        currentValue: currentValue,
        onChanged: onChanged,
      ),
    );
  }

  /// 显示编辑底部弹窗
  void _showEditBottomSheet(
    BuildContext context, {
    required String title,
    required String hintText,
    required String initialValue,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    required Function(String?) onSaved,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditBottomSheet(
        title: title,
        hintText: hintText,
        initialValue: initialValue,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onSaved: onSaved,
      ),
    );
  }

  static Widget _flightShuttleBuilder(
    BuildContext context,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return Icon(
      Icons.settings_outlined,
      size: 24,
      color: Theme.of(fromHeroContext).colorScheme.onSurface,
    );
  }
}

/// 设置项组件
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;
  final bool showArrow;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }
}

/// 编辑底部弹窗
class _EditBottomSheet extends StatefulWidget {
  final String title;
  final String hintText;
  final String initialValue;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String?) onSaved;

  const _EditBottomSheet({
    required this.title,
    required this.hintText,
    required this.initialValue,
    this.keyboardType,
    this.inputFormatters,
    required this.onSaved,
  });

  @override
  State<_EditBottomSheet> createState() => _EditBottomSheetState();
}

class _EditBottomSheetState extends State<_EditBottomSheet> {
  late final TextEditingController _controller;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _isValid = _controller.text.isNotEmpty;
    _controller.addListener(_validateInput);
  }

  void _validateInput() {
    setState(() {
      _isValid = _controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题栏
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _isValid
                        ? () {
                            widget.onSaved(_controller.text);
                            Navigator.pop(context);
                          }
                        : null,
                    child: const Text('保存'),
                  ),
                ],
              ),
            ),
            // 输入框
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: TextField(
                controller: _controller,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _controller.clear();
                          },
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 数据源切换弹窗（模拟数据 / 真实接口）
class _MockToggleSheet extends StatefulWidget {
  final bool currentValue;
  final ValueChanged<bool> onChanged;

  const _MockToggleSheet({
    required this.currentValue,
    required this.onChanged,
  });

  @override
  State<_MockToggleSheet> createState() => _MockToggleSheetState();
}

class _MockToggleSheetState extends State<_MockToggleSheet> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.currentValue;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '选择数据源',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            RadioGroup<bool>(
              groupValue: _value,
              onChanged: (v) {
                if (v == null) return;
                setState(() => _value = v);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<bool>(
                    value: true,
                    title: const Text('模拟数据'),
                    subtitle: const Text('无需后端和 API Key，开箱即用'),
                  ),
                  RadioListTile<bool>(
                    value: false,
                    title: const Text('真实接口'),
                    subtitle: const Text('需配置接口地址、API Key 和模型名'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => widget.onChanged(_value),
                  child: const Text('确定'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
