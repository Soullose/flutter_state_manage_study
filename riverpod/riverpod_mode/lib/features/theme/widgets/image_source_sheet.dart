import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// 图片来源选择底部弹窗
///
/// 提供从相册选择或输入网络URL两种方式
class ImageSourceSheet extends StatefulWidget {
  /// 从本地相册选择图片的回调
  final void Function(String path) onLocalImageSelected;

  /// 从网络URL加载图片的回调
  final void Function(String url) onNetworkImageSelected;

  const ImageSourceSheet({
    super.key,
    required this.onLocalImageSelected,
    required this.onNetworkImageSelected,
  });

  /// 显示图片来源选择弹窗
  static Future<void> show({
    required BuildContext context,
    required void Function(String path) onLocalImageSelected,
    required void Function(String url) onNetworkImageSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImageSourceSheet(
        onLocalImageSelected: onLocalImageSelected,
        onNetworkImageSelected: onNetworkImageSelected,
      ),
    );
  }

  @override
  State<ImageSourceSheet> createState() => _ImageSourceSheetState();
}

class _ImageSourceSheetState extends State<ImageSourceSheet> {
  final _urlController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    if (_isLoading) return;

    debugPrint('[ImageSourceSheet] 开始选择图片');
    setState(() {
      _isLoading = true;
    });

    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      debugPrint('[ImageSourceSheet] 选择结果: ${image?.path}');
      if (image != null) {
        if (mounted) {
          Navigator.pop(context);
          widget.onLocalImageSelected(image.path);
        }
      } else {
        debugPrint('[ImageSourceSheet] 用户取消选择');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e, stackTrace) {
      debugPrint('[ImageSourceSheet] 选择图片错误: $e');
      debugPrint('[ImageSourceSheet] 堆栈: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择图片失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _submitNetworkUrl() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入图片URL')));
      return;
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入有效的URL地址')));
      return;
    }

    Navigator.pop(context);
    widget.onNetworkImageSelected(url);
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  '选择图片来源',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),

                // 从相册选择
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          )
                        : Icon(
                            Icons.photo_library,
                            color: colorScheme.onPrimaryContainer,
                          ),
                  ),
                  title: const Text('从相册选择'),
                  subtitle: Text(_isLoading ? '正在打开相册...' : '选择本地图片生成主题'),
                  trailing: _isLoading ? null : const Icon(Icons.chevron_right),
                  onTap: _isLoading ? null : _pickFromGallery,
                ),
                const SizedBox(height: 16),

                // 分隔线
                Row(
                  children: [
                    Expanded(child: Divider(color: colorScheme.outlineVariant)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '或者',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    Expanded(child: Divider(color: colorScheme.outlineVariant)),
                  ],
                ),
                const SizedBox(height: 16),

                // 网络URL输入
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: '图片URL',
                    hintText: 'https://example.com/image.jpg',
                    prefixIcon: const Icon(Icons.link),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _urlController.clear(),
                    ),
                  ),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submitNetworkUrl(),
                ),
                const SizedBox(height: 16),

                // 确认按钮
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _submitNetworkUrl,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: const Text('使用网络图片'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
