// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Provider状态管理学习';

  @override
  String get toggleTheme => '切换主题';

  @override
  String get welcomeMessage => '欢迎学习Provider状态管理';

  @override
  String get welcomeSubtitle => '点击下方卡片探索不同的Provider使用场景';

  @override
  String get providerExamples => 'Provider示例';

  @override
  String get currentStatus => '当前状态';

  @override
  String get counter => '计数器';

  @override
  String get counterSubtitle => '基础状态管理';

  @override
  String get themeSwitch => '主题切换';

  @override
  String get themeSwitchSubtitle => '亮色/暗色/系统';

  @override
  String get multiLanguage => '多语言';

  @override
  String get multiLanguageSubtitle => '中文/English';

  @override
  String get appSettings => '应用设置';

  @override
  String get appSettingsSubtitle => '复杂对象管理';

  @override
  String get errorLog => '错误日志';

  @override
  String get errorLogSubtitle => '异常日志管理';

  @override
  String get currentTheme => '当前主题';

  @override
  String get selectTheme => '选择主题';

  @override
  String get themeLight => '亮色模式';

  @override
  String get themeDark => '暗色模式';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get currentLanguage => '当前语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get notificationSettings => '通知设置';

  @override
  String get pushNotification => '推送通知';

  @override
  String get pushNotificationSubtitle => '接收应用通知';

  @override
  String get sound => '声音';

  @override
  String get soundSubtitle => '播放提示音';

  @override
  String get vibration => '振动';

  @override
  String get vibrationSubtitle => '触觉反馈';

  @override
  String get privacySettings => '隐私设置';

  @override
  String get autoUpdateCheck => '自动检查更新';

  @override
  String get autoUpdateCheckSubtitle => '启动时检查新版本';

  @override
  String get analytics => '数据统计';

  @override
  String get analyticsSubtitle => '帮助改进应用体验';

  @override
  String get storage => '存储';

  @override
  String get cache => '缓存';

  @override
  String get clearCache => '清除缓存';

  @override
  String get exportLog => '导出日志';

  @override
  String get clearAllLogs => '清空所有日志';

  @override
  String get clearWeekOldLogs => '清除一周前的日志';

  @override
  String get refresh => '刷新';

  @override
  String get searchLog => '搜索日志...';

  @override
  String get allLevels => '全部级别';

  @override
  String get selectDateRange => '选择日期范围';

  @override
  String get totalLogs => '总计日志';

  @override
  String get errorCount => '错误';

  @override
  String get warningCount => '警告';

  @override
  String get infoCount => '信息';

  @override
  String get noLogs => '暂无日志记录';

  @override
  String get noMatchingLogs => '没有匹配的日志记录';

  @override
  String get logDetail => '日志详情';

  @override
  String get copy => '复制';

  @override
  String get share => '分享';

  @override
  String get delete => '删除';

  @override
  String get message => '消息';

  @override
  String get errorType => '错误类型';

  @override
  String get source => '来源';

  @override
  String get stackTrace => '堆栈跟踪';

  @override
  String get additionalData => '附加数据';

  @override
  String get deviceInfo => '设备信息';

  @override
  String get appVersion => '应用版本';

  @override
  String get deviceModel => '设备型号';

  @override
  String get manufacturer => '制造商';

  @override
  String get systemVersion => '系统版本';

  @override
  String get platform => '平台';

  @override
  String get networkType => '网络类型';

  @override
  String get networkStatus => '网络连接';

  @override
  String get timezone => '时区';

  @override
  String get language => '语言';

  @override
  String get connected => '已连接';

  @override
  String get disconnected => '未连接';

  @override
  String get confirmDelete => '确认删除';

  @override
  String get confirmDeleteMessage => '确定要删除这条日志吗？';

  @override
  String get confirmClearAll => '确认清空';

  @override
  String get confirmClearAllMessage => '确定要清空所有日志吗？此操作不可恢复。';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get copiedToClipboard => '已复制到剪贴板';

  @override
  String get logExported => '日志已导出';

  @override
  String get logDeleted => '日志已删除';

  @override
  String get logsCleared => '日志已清空';

  @override
  String get operationFailed => '操作失败';

  @override
  String get increment => '增加';

  @override
  String get decrement => '减少';

  @override
  String get reset => '重置';

  @override
  String get currentCount => '当前计数';

  @override
  String get resetToDefault => '重置为默认';

  @override
  String get themeSettings => '主题设置';

  @override
  String get providerUsageInfo => 'Provider使用说明';

  @override
  String get providerUsageDetails =>
      '• 使用 ChangeNotifier 管理主题状态\n• 主题更改会自动通知所有监听者\n• 主题偏好持久化存储\n• 支持亮色、暗色和跟随系统三种模式';

  @override
  String cacheSize(int size) {
    return '当前缓存: $size MB';
  }

  @override
  String get clearCacheButton => '清理';

  @override
  String get resetSettings => '重置设置';

  @override
  String get resetSettingsConfirm => '确定要将所有设置恢复为默认值吗？';

  @override
  String get settingsReset => '设置已重置';

  @override
  String get clearCacheTitle => '清理缓存';

  @override
  String get clearCacheConfirm => '确定要清理所有缓存数据吗？';

  @override
  String get cacheCleared => '缓存已清理';

  @override
  String get complexStateManagementInfo => '复杂状态管理说明';

  @override
  String get complexStateManagementDetails =>
      '• AppSettings 使用 Equatable 方便比较\n• 使用 copyWith 创建不可变对象的副本\n• 设置以JSON格式持久化存储\n• 每次修改都会保存到本地';

  @override
  String get localeUsageInfo => '国际化使用说明';

  @override
  String get localeUsageDetails =>
      '• LocaleProvider 管理应用语言状态\n• 返回null表示跟随系统语言设置\n• 需要配合MaterialApp.locale使用\n• 完整国际化需要arb文件和intl包';

  @override
  String get retry => '重试';

  @override
  String get appRunningNormally => '应用运行正常';

  @override
  String get logLevel => '日志级别';

  @override
  String get all => '全部';

  @override
  String get errorLevel => '错误';

  @override
  String get warningLevel => '警告';

  @override
  String get infoLevel => '信息';

  @override
  String get debugLevel => '调试';

  @override
  String get selectDate => '选择日期';

  @override
  String get clearFilter => '清除筛选';

  @override
  String get confirmClearWeekLogs => '确定要清除一周前的日志吗？';

  @override
  String get weekOldLogsCleared => '一周前的日志已清除';

  @override
  String get testException => '测试异常';

  @override
  String get testExceptionMessage => '这是一个测试异常';

  @override
  String get generateError => '生成错误';

  @override
  String get generateWarning => '生成警告';

  @override
  String get generateInfo => '生成信息';

  @override
  String get testErrorGenerated => '测试错误已生成';

  @override
  String get testWarningGenerated => '测试警告已生成';

  @override
  String get testInfoGenerated => '测试信息已生成';

  @override
  String get selectExportFormat => '选择导出格式：';

  @override
  String get readableText => '可读文本';

  @override
  String get exporting => '正在导出...';

  @override
  String get logExportSubject => '错误日志导出';

  @override
  String get exportFailedOrNoLogs => '导出失败或没有日志可导出';

  @override
  String get testLogFunction => '测试日志功能';

  @override
  String get testErrorLog => '测试错误日志';

  @override
  String get testWarningLog => '测试警告日志';

  @override
  String get testInfoLog => '测试信息日志';

  @override
  String get throwTestException => '抛出测试异常';

  @override
  String get time => '时间';

  @override
  String get errorMessage => '错误消息';

  @override
  String get logDetailSubject => '错误日志详情';
}
