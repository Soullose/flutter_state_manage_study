import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/error_log_entry.dart';

/// 设备信息收集器
class DeviceInfoCollector {
  static final DeviceInfoCollector _instance = DeviceInfoCollector._internal();
  factory DeviceInfoCollector() => _instance;
  DeviceInfoCollector._internal();

  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  PackageInfo? _packageInfo;

  /// 初始化（应在应用启动时调用）
  Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  /// 收集设备信息
  Future<DeviceInfo> collect() async {
    final packageInfo = _packageInfo ?? await PackageInfo.fromPlatform();

    if (kIsWeb) {
      return _collectWebInfo(packageInfo);
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _collectAndroidInfo(packageInfo);
      case TargetPlatform.iOS:
        return _collectIOSInfo(packageInfo);
      case TargetPlatform.windows:
        return _collectWindowsInfo(packageInfo);
      case TargetPlatform.macOS:
        return _collectMacOSInfo(packageInfo);
      case TargetPlatform.linux:
        return _collectLinuxInfo(packageInfo);
      case TargetPlatform.fuchsia:
        return _collectFuchsiaInfo(packageInfo);
    }
  }

  Future<DeviceInfo> _collectAndroidInfo(PackageInfo packageInfo) async {
    final info = await _deviceInfoPlugin.androidInfo;
    return DeviceInfo(
      platform: 'android',
      osVersion: '${info.version.sdkInt}',
      deviceModel: info.model,
      appVersion: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      deviceId: info.id,
      brand: info.brand,
      manufacturer: info.manufacturer,
      language: Platform.localeName,
      screenResolution: null, // 需要在有 context 的地方获取
      isPhysicalDevice: info.isPhysicalDevice,
    );
  }

  Future<DeviceInfo> _collectIOSInfo(PackageInfo packageInfo) async {
    final info = await _deviceInfoPlugin.iosInfo;
    return DeviceInfo(
      platform: 'ios',
      osVersion: info.systemVersion,
      deviceModel: info.model,
      appVersion: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      deviceId: info.identifierForVendor,
      brand: 'Apple',
      manufacturer: 'Apple',
      language: Platform.localeName,
      screenResolution: null,
      isPhysicalDevice: info.isPhysicalDevice,
    );
  }

  Future<DeviceInfo> _collectWindowsInfo(PackageInfo packageInfo) async {
    final info = await _deviceInfoPlugin.windowsInfo;
    return DeviceInfo(
      platform: 'windows',
      osVersion:
          '${info.majorVersion}.${info.minorVersion}.${info.buildNumber}',
      deviceModel: info.computerName,
      appVersion: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      language: Platform.localeName,
      isPhysicalDevice: true,
    );
  }

  Future<DeviceInfo> _collectMacOSInfo(PackageInfo packageInfo) async {
    final info = await _deviceInfoPlugin.macOsInfo;
    return DeviceInfo(
      platform: 'macos',
      osVersion:
          '${info.majorVersion}.${info.minorVersion}.${info.patchVersion}',
      deviceModel: info.model,
      appVersion: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      language: Platform.localeName,
      isPhysicalDevice: true,
    );
  }

  Future<DeviceInfo> _collectLinuxInfo(PackageInfo packageInfo) async {
    final info = await _deviceInfoPlugin.linuxInfo;
    return DeviceInfo(
      platform: 'linux',
      osVersion: info.prettyName,
      deviceModel: info.name,
      appVersion: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      language: Platform.localeName,
      isPhysicalDevice: true,
    );
  }

  Future<DeviceInfo> _collectWebInfo(PackageInfo packageInfo) async {
    final info = await _deviceInfoPlugin.webBrowserInfo;
    return DeviceInfo(
      platform: 'web',
      osVersion: info.platform ?? 'unknown',
      deviceModel: info.browserName.name,
      appVersion: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      language: info.language,
      isPhysicalDevice: true,
    );
  }

  Future<DeviceInfo> _collectFuchsiaInfo(PackageInfo packageInfo) async {
    return DeviceInfo(
      platform: 'fuchsia',
      osVersion: 'unknown',
      deviceModel: 'unknown',
      appVersion: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      language: Platform.localeName,
      isPhysicalDevice: true,
    );
  }
}
