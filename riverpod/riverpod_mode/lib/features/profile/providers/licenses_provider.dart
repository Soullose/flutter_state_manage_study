import 'package:flutter_riverpod/flutter_riverpod.dart';

// 导入 flutter_oss_licenses 生成的文件
import '../../../oss_licenses.dart';

/// 开源协议列表 Provider
///
/// 直接使用 flutter_oss_licenses 生成的 allDependencies 列表
final licensesProvider = Provider<List<Package>>((ref) {
  // 过滤掉 SDK 包，只显示第三方依赖
  final packages = allDependencies.where((pkg) => !pkg.isSdk).toList();

  // 按包名排序
  packages.sort((a, b) => a.name.compareTo(b.name));

  return packages;
});

/// 搜索过滤后的开源协议列表 Provider
final filteredLicensesProvider = Provider.family<List<Package>, String>((
  ref,
  query,
) {
  final licenses = ref.watch(licensesProvider);

  if (query.isEmpty) {
    return licenses;
  }

  final lowerQuery = query.toLowerCase();
  return licenses.where((license) {
    return license.name.toLowerCase().contains(lowerQuery) ||
        license.description.toLowerCase().contains(lowerQuery);
  }).toList();
});
