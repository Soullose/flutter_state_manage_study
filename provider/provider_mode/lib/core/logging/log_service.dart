// lib/core/logging/log_service.dart

import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'log_file_service.dart';
import 'models/log_entry.dart';
import 'models/log_metadata.dart';

/// 日志服务核心类
/// 提供日志记录、查询、导出等功能
class LogService {
  final LogFileService _fileService;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Connectivity _connectivity = Connectivity();

  /// 缓存的元数据
  LogMetadata? _cachedMetadata;

  /// 是否已初始化
  bool _isInitialized = false;

  /// 日志更新通知流控制器
  final StreamController<void> _logUpdateController =
      StreamController<void>.broadcast();

  /// 日志更新通知流
  Stream<void> get onLogUpdate => _logUpdateController.stream;

  LogService({LogFileService? fileService})
      : _fileService = fileService ?? LogFileService();

  /// 初始化日志服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 预加载元数据
      await _loadMetadata();
      _isInitialized = true;
      debugPrint('[LogService] Initialized successfully');
    } catch (e) {
      debugPrint('[LogService] Failed to initialize: $e');
    }
  }

  /// 加载设备和应用元数据
  Future<void> _loadMetadata() async {
    try {
      final packageInfo = await _getPackageInfo();
      final deviceData = await _getDeviceInfo();
      final connectivityResult = await _getConnectivityStatus();

      _cachedMetadata = LogMetadata(
        appVersion: packageInfo['version'] ?? 'unknown',
        buildNumber: packageInfo['buildNumber'] ?? 'unknown',
        deviceModel: deviceData['model'] ?? 'unknown',
        deviceManufacturer: deviceData['manufacturer'],
        osVersion: deviceData['osVersion'] ?? 'unknown',
        platform: deviceData['platform'] ?? Platform.operatingSystem,
        networkType: connectivityResult['networkType'],
        isConnected: connectivityResult['isConnected'],
        screenResolution: deviceData['screenResolution'],
        timezone: DateTime.now().timeZoneName,
        locale: Platform.localeName,
      );
    } catch (e) {
      debugPrint('[LogService] Failed to load metadata: $e');
      _cachedMetadata = LogMetadata.empty();
    }
  }

  /// 获取应用包信息
  Future<Map<String, String>> _getPackageInfo() async {
    // 由于没有package_info_plus，我们返回默认值
    // 实际项目中可以添加package_info_plus依赖
    return {
      'version': '1.0.0',
      'buildNumber': '1',
    };
  }

  /// 获取设备信息
  Future<Map<String, String?>> _getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'osVersion': 'Android ${androidInfo.version.release}',
          'platform': 'Android',
          'screenResolution': null, // 需要通过MediaQuery获取
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'model': iosInfo.model,
          'manufacturer': 'Apple',
          'osVersion': 'iOS ${iosInfo.systemVersion}',
          'platform': 'iOS',
          'screenResolution': null,
        };
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        return {
          'model': macInfo.model,
          'manufacturer': 'Apple',
          'osVersion': 'macOS ${macInfo.osRelease}',
          'platform': 'macOS',
          'screenResolution': null,
        };
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return {
          'model': 'Windows PC',
          'manufacturer': null,
          'osVersion': 'Windows',
          'platform': 'Windows',
          'screenResolution': null,
        };
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        return {
          'model': linuxInfo.prettyName,
          'manufacturer': null,
          'osVersion': linuxInfo.version ?? 'Linux',
          'platform': 'Linux',
          'screenResolution': null,
        };
      }
    } on PlatformException catch (e) {
      debugPrint('[LogService] Failed to get device info: $e');
    }

    return {
      'model': 'unknown',
      'osVersion': 'unknown',
      'platform': Platform.operatingSystem,
    };
  }

  /// 获取网络连接状态
  Future<Map<String, dynamic>> _getConnectivityStatus() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final isConnected = result != ConnectivityResult.none;

      String? networkType;
      switch (result) {
        case ConnectivityResult.wifi:
          networkType = 'WiFi';
          break;
        case ConnectivityResult.mobile:
          networkType = 'Cellular';
          break;
        case ConnectivityResult.ethernet:
          networkType = 'Ethernet';
          break;
        case ConnectivityResult.none:
          networkType = 'None';
          break;
        default:
          networkType = 'Unknown';
      }

      return {
        'networkType': networkType,
        'isConnected': isConnected,
      };
    } catch (e) {
      debugPrint('[LogService] Failed to get connectivity status: $e');
      return {
        'networkType': null,
        'isConnected': null,
      };
    }
  }

  /// 刷新元数据（获取最新的网络状态等）
  Future<LogMetadata> _getFreshMetadata() async {
    if (_cachedMetadata == null) {
      await _loadMetadata();
    }

    // 获取最新的网络状态
    final connectivityResult = await _getConnectivityStatus();

    return _cachedMetadata!.copyWith(
      networkType: connectivityResult['networkType'],
      isConnected: connectivityResult['isConnected'],
    );
  }

  /// 记录错误日志
  Future<void> logError(
    dynamic error, [
    StackTrace? stackTrace,
    String? source,
    Map<String, dynamic>? additionalData,
  ]) async {
    try {
      final metadata = await _getFreshMetadata();
      final entry = LogEntry.create(
        level: LogLevel.error,
        message: error.toString(),
        stackTrace: stackTrace?.toString(),
        errorType: error.runtimeType.toString(),
        source: source,
        additionalData: additionalData,
        metadata: metadata,
      );

      await _fileService.writeLogEntry(entry);
      debugPrint('[LogService] Error logged: ${entry.message}');

      // 通知日志更新
      // _notifyLogUpdated();
    } catch (e) {
      debugPrint('[LogService] Failed to log error: $e');
    }
  }

  /// 记录警告日志
  Future<void> logWarning(
    String message, [
    String? source,
    Map<String, dynamic>? additionalData,
  ]) async {
    try {
      final metadata = await _getFreshMetadata();
      final entry = LogEntry.create(
        level: LogLevel.warning,
        message: message,
        source: source,
        additionalData: additionalData,
        metadata: metadata,
      );

      await _fileService.writeLogEntry(entry);
    } catch (e) {
      debugPrint('[LogService] Failed to log warning: $e');
    }
  }

  /// 记录信息日志
  Future<void> logInfo(
    String message, [
    String? source,
    Map<String, dynamic>? additionalData,
  ]) async {
    try {
      final metadata = await _getFreshMetadata();
      final entry = LogEntry.create(
        level: LogLevel.info,
        message: message,
        source: source,
        additionalData: additionalData,
        metadata: metadata,
      );

      await _fileService.writeLogEntry(entry);
    } catch (e) {
      debugPrint('[LogService] Failed to log info: $e');
    }
  }

  /// 记录调试日志
  Future<void> logDebug(
    String message, [
    String? source,
    Map<String, dynamic>? additionalData,
  ]) async {
    if (!kDebugMode) return;

    try {
      final metadata = await _getFreshMetadata();
      final entry = LogEntry.create(
        level: LogLevel.debug,
        message: message,
        source: source,
        additionalData: additionalData,
        metadata: metadata,
      );

      await _fileService.writeLogEntry(entry);
    } catch (e) {
      debugPrint('[LogService] Failed to log debug: $e');
    }
  }

  /// 获取所有日志
  Future<List<LogEntry>> getAllLogs() async {
    return _fileService.readAllLogs();
  }

  /// 获取日志（带筛选和分页）
  Future<List<LogEntry>> getLogs({
    LogFilter? filter,
    int? limit,
    int? offset,
  }) async {
    return _fileService.readLogs(
      filter: filter,
      limit: limit,
      offset: offset,
    );
  }

  /// 获取日志统计信息
  Future<LogStatistics> getStatistics() async {
    return _fileService.getStatistics();
  }

  /// 获取日志目录路径
  Future<String> getLogsDirectory() async {
    return _fileService.getLogDirectory();
  }

  /// 清除指定日期之前的日志
  Future<int> clearLogsBefore(DateTime date) async {
    return _fileService.deleteLogsBefore(date);
  }

  /// 清除所有日志
  Future<int> clearAllLogs() async {
    return _fileService.clearAllLogs();
  }

  /// 导出日志
  Future<File?> exportLogs({
    LogFilter? filter,
    bool readable = true,
  }) async {
    return _fileService.exportLogs(
      filter: filter,
      readable: readable,
    );
  }

  /// 获取日志文件路径列表
  Future<List<String>> getLogFilePaths() async {
    return _fileService.getLogFilePaths();
  }

  /// 获取当前缓存的元数据
  LogMetadata? get currentMetadata => _cachedMetadata;

  /// 是否已初始化
  bool get isInitialized => _isInitialized;
}
