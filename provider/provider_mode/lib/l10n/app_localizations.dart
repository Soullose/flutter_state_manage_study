import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// 应用标题
  ///
  /// In zh, this message translates to:
  /// **'Provider状态管理学习'**
  String get appTitle;

  /// 切换主题按钮提示
  ///
  /// In zh, this message translates to:
  /// **'切换主题'**
  String get toggleTheme;

  /// 欢迎卡片标题
  ///
  /// In zh, this message translates to:
  /// **'欢迎学习Provider状态管理'**
  String get welcomeMessage;

  /// 欢迎卡片副标题
  ///
  /// In zh, this message translates to:
  /// **'点击下方卡片探索不同的Provider使用场景'**
  String get welcomeSubtitle;

  /// Provider示例分组标题
  ///
  /// In zh, this message translates to:
  /// **'Provider示例'**
  String get providerExamples;

  /// 当前状态分组标题
  ///
  /// In zh, this message translates to:
  /// **'当前状态'**
  String get currentStatus;

  /// 计数器示例标题
  ///
  /// In zh, this message translates to:
  /// **'计数器'**
  String get counter;

  /// 计数器示例副标题
  ///
  /// In zh, this message translates to:
  /// **'基础状态管理'**
  String get counterSubtitle;

  /// 主题切换示例标题
  ///
  /// In zh, this message translates to:
  /// **'主题切换'**
  String get themeSwitch;

  /// 主题切换示例副标题
  ///
  /// In zh, this message translates to:
  /// **'亮色/暗色/系统'**
  String get themeSwitchSubtitle;

  /// 多语言示例标题
  ///
  /// In zh, this message translates to:
  /// **'多语言'**
  String get multiLanguage;

  /// 多语言示例副标题
  ///
  /// In zh, this message translates to:
  /// **'中文/English'**
  String get multiLanguageSubtitle;

  /// 应用设置示例标题
  ///
  /// In zh, this message translates to:
  /// **'应用设置'**
  String get appSettings;

  /// 应用设置示例副标题
  ///
  /// In zh, this message translates to:
  /// **'复杂对象管理'**
  String get appSettingsSubtitle;

  /// 错误日志示例标题
  ///
  /// In zh, this message translates to:
  /// **'错误日志'**
  String get errorLog;

  /// 错误日志示例副标题
  ///
  /// In zh, this message translates to:
  /// **'异常日志管理'**
  String get errorLogSubtitle;

  /// 当前主题显示标签
  ///
  /// In zh, this message translates to:
  /// **'当前主题'**
  String get currentTheme;

  /// 选择主题标题
  ///
  /// In zh, this message translates to:
  /// **'选择主题'**
  String get selectTheme;

  /// 亮色主题
  ///
  /// In zh, this message translates to:
  /// **'亮色模式'**
  String get themeLight;

  /// 暗色主题
  ///
  /// In zh, this message translates to:
  /// **'暗色模式'**
  String get themeDark;

  /// 跟随系统主题
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get themeSystem;

  /// 当前语言显示标签
  ///
  /// In zh, this message translates to:
  /// **'当前语言'**
  String get currentLanguage;

  /// 选择语言标题
  ///
  /// In zh, this message translates to:
  /// **'选择语言'**
  String get selectLanguage;

  /// 中文语言名称
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get languageChinese;

  /// 英文语言名称
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// 跟随系统语言
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get languageSystem;

  /// 通知设置分组标题
  ///
  /// In zh, this message translates to:
  /// **'通知设置'**
  String get notificationSettings;

  /// 推送通知设置项
  ///
  /// In zh, this message translates to:
  /// **'推送通知'**
  String get pushNotification;

  /// 推送通知设置项副标题
  ///
  /// In zh, this message translates to:
  /// **'接收应用通知'**
  String get pushNotificationSubtitle;

  /// 声音设置项
  ///
  /// In zh, this message translates to:
  /// **'声音'**
  String get sound;

  /// 声音设置项副标题
  ///
  /// In zh, this message translates to:
  /// **'播放提示音'**
  String get soundSubtitle;

  /// 振动设置项
  ///
  /// In zh, this message translates to:
  /// **'振动'**
  String get vibration;

  /// 振动设置项副标题
  ///
  /// In zh, this message translates to:
  /// **'触觉反馈'**
  String get vibrationSubtitle;

  /// 隐私设置分组标题
  ///
  /// In zh, this message translates to:
  /// **'隐私设置'**
  String get privacySettings;

  /// 自动检查更新设置项
  ///
  /// In zh, this message translates to:
  /// **'自动检查更新'**
  String get autoUpdateCheck;

  /// 自动检查更新设置项副标题
  ///
  /// In zh, this message translates to:
  /// **'启动时检查新版本'**
  String get autoUpdateCheckSubtitle;

  /// 数据统计设置项
  ///
  /// In zh, this message translates to:
  /// **'数据统计'**
  String get analytics;

  /// 数据统计设置项副标题
  ///
  /// In zh, this message translates to:
  /// **'帮助改进应用体验'**
  String get analyticsSubtitle;

  /// 存储分组标题
  ///
  /// In zh, this message translates to:
  /// **'存储'**
  String get storage;

  /// 缓存设置项
  ///
  /// In zh, this message translates to:
  /// **'缓存'**
  String get cache;

  /// 清除缓存按钮
  ///
  /// In zh, this message translates to:
  /// **'清除缓存'**
  String get clearCache;

  /// 导出日志按钮提示
  ///
  /// In zh, this message translates to:
  /// **'导出日志'**
  String get exportLog;

  /// 清空所有日志菜单项
  ///
  /// In zh, this message translates to:
  /// **'清空所有日志'**
  String get clearAllLogs;

  /// 清除一周前的日志菜单项
  ///
  /// In zh, this message translates to:
  /// **'清除一周前的日志'**
  String get clearWeekOldLogs;

  /// 刷新菜单项
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get refresh;

  /// 搜索日志输入框提示
  ///
  /// In zh, this message translates to:
  /// **'搜索日志...'**
  String get searchLog;

  /// 全部级别筛选选项
  ///
  /// In zh, this message translates to:
  /// **'全部级别'**
  String get allLevels;

  /// 选择日期范围按钮
  ///
  /// In zh, this message translates to:
  /// **'选择日期范围'**
  String get selectDateRange;

  /// 总计日志标签
  ///
  /// In zh, this message translates to:
  /// **'总计日志'**
  String get totalLogs;

  /// 错误数量标签
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get errorCount;

  /// 警告数量标签
  ///
  /// In zh, this message translates to:
  /// **'警告'**
  String get warningCount;

  /// 信息数量标签
  ///
  /// In zh, this message translates to:
  /// **'信息'**
  String get infoCount;

  /// 无日志记录提示
  ///
  /// In zh, this message translates to:
  /// **'暂无日志记录'**
  String get noLogs;

  /// 无匹配日志提示
  ///
  /// In zh, this message translates to:
  /// **'没有匹配的日志记录'**
  String get noMatchingLogs;

  /// 日志详情页面标题
  ///
  /// In zh, this message translates to:
  /// **'日志详情'**
  String get logDetail;

  /// 复制按钮
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get copy;

  /// 分享按钮
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get share;

  /// 删除按钮
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// 消息标签
  ///
  /// In zh, this message translates to:
  /// **'消息'**
  String get message;

  /// 错误类型标签
  ///
  /// In zh, this message translates to:
  /// **'错误类型'**
  String get errorType;

  /// 来源标签
  ///
  /// In zh, this message translates to:
  /// **'来源'**
  String get source;

  /// 堆栈跟踪标签
  ///
  /// In zh, this message translates to:
  /// **'堆栈跟踪'**
  String get stackTrace;

  /// 附加数据标签
  ///
  /// In zh, this message translates to:
  /// **'附加数据'**
  String get additionalData;

  /// 设备信息标签
  ///
  /// In zh, this message translates to:
  /// **'设备信息'**
  String get deviceInfo;

  /// 应用版本标签
  ///
  /// In zh, this message translates to:
  /// **'应用版本'**
  String get appVersion;

  /// 设备型号标签
  ///
  /// In zh, this message translates to:
  /// **'设备型号'**
  String get deviceModel;

  /// 制造商标签
  ///
  /// In zh, this message translates to:
  /// **'制造商'**
  String get manufacturer;

  /// 系统版本标签
  ///
  /// In zh, this message translates to:
  /// **'系统版本'**
  String get systemVersion;

  /// 平台标签
  ///
  /// In zh, this message translates to:
  /// **'平台'**
  String get platform;

  /// 网络类型标签
  ///
  /// In zh, this message translates to:
  /// **'网络类型'**
  String get networkType;

  /// 网络连接标签
  ///
  /// In zh, this message translates to:
  /// **'网络连接'**
  String get networkStatus;

  /// 时区标签
  ///
  /// In zh, this message translates to:
  /// **'时区'**
  String get timezone;

  /// 语言标签
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// 已连接状态
  ///
  /// In zh, this message translates to:
  /// **'已连接'**
  String get connected;

  /// 未连接状态
  ///
  /// In zh, this message translates to:
  /// **'未连接'**
  String get disconnected;

  /// 确认删除对话框标题
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get confirmDelete;

  /// 确认删除对话框内容
  ///
  /// In zh, this message translates to:
  /// **'确定要删除这条日志吗？'**
  String get confirmDeleteMessage;

  /// 确认清空对话框标题
  ///
  /// In zh, this message translates to:
  /// **'确认清空'**
  String get confirmClearAll;

  /// 确认清空对话框内容
  ///
  /// In zh, this message translates to:
  /// **'确定要清空所有日志吗？此操作不可恢复。'**
  String get confirmClearAllMessage;

  /// 取消按钮
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// 确认按钮
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  /// 复制成功提示
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板'**
  String get copiedToClipboard;

  /// 导出成功提示
  ///
  /// In zh, this message translates to:
  /// **'日志已导出'**
  String get logExported;

  /// 删除成功提示
  ///
  /// In zh, this message translates to:
  /// **'日志已删除'**
  String get logDeleted;

  /// 清空成功提示
  ///
  /// In zh, this message translates to:
  /// **'日志已清空'**
  String get logsCleared;

  /// 操作失败提示
  ///
  /// In zh, this message translates to:
  /// **'操作失败'**
  String get operationFailed;

  /// 增加按钮
  ///
  /// In zh, this message translates to:
  /// **'增加'**
  String get increment;

  /// 减少按钮
  ///
  /// In zh, this message translates to:
  /// **'减少'**
  String get decrement;

  /// 重置按钮
  ///
  /// In zh, this message translates to:
  /// **'重置'**
  String get reset;

  /// 当前计数标签
  ///
  /// In zh, this message translates to:
  /// **'当前计数'**
  String get currentCount;

  /// 重置为默认按钮提示
  ///
  /// In zh, this message translates to:
  /// **'重置为默认'**
  String get resetToDefault;

  /// 主题设置页面标题
  ///
  /// In zh, this message translates to:
  /// **'主题设置'**
  String get themeSettings;

  /// Provider使用说明标题
  ///
  /// In zh, this message translates to:
  /// **'Provider使用说明'**
  String get providerUsageInfo;

  /// Provider使用说明详情
  ///
  /// In zh, this message translates to:
  /// **'• 使用 ChangeNotifier 管理主题状态\n• 主题更改会自动通知所有监听者\n• 主题偏好持久化存储\n• 支持亮色、暗色和跟随系统三种模式'**
  String get providerUsageDetails;

  /// 缓存大小显示
  ///
  /// In zh, this message translates to:
  /// **'当前缓存: {size} MB'**
  String cacheSize(int size);

  /// 清理缓存按钮
  ///
  /// In zh, this message translates to:
  /// **'清理'**
  String get clearCacheButton;

  /// 重置设置对话框标题
  ///
  /// In zh, this message translates to:
  /// **'重置设置'**
  String get resetSettings;

  /// 重置设置确认内容
  ///
  /// In zh, this message translates to:
  /// **'确定要将所有设置恢复为默认值吗？'**
  String get resetSettingsConfirm;

  /// 设置已重置提示
  ///
  /// In zh, this message translates to:
  /// **'设置已重置'**
  String get settingsReset;

  /// 清理缓存对话框标题
  ///
  /// In zh, this message translates to:
  /// **'清理缓存'**
  String get clearCacheTitle;

  /// 清理缓存确认内容
  ///
  /// In zh, this message translates to:
  /// **'确定要清理所有缓存数据吗？'**
  String get clearCacheConfirm;

  /// 缓存已清理提示
  ///
  /// In zh, this message translates to:
  /// **'缓存已清理'**
  String get cacheCleared;

  /// 复杂状态管理说明标题
  ///
  /// In zh, this message translates to:
  /// **'复杂状态管理说明'**
  String get complexStateManagementInfo;

  /// 复杂状态管理说明详情
  ///
  /// In zh, this message translates to:
  /// **'• AppSettings 使用 Equatable 方便比较\n• 使用 copyWith 创建不可变对象的副本\n• 设置以JSON格式持久化存储\n• 每次修改都会保存到本地'**
  String get complexStateManagementDetails;

  /// 国际化使用说明标题
  ///
  /// In zh, this message translates to:
  /// **'国际化使用说明'**
  String get localeUsageInfo;

  /// 国际化使用说明详情
  ///
  /// In zh, this message translates to:
  /// **'• LocaleProvider 管理应用语言状态\n• 返回null表示跟随系统语言设置\n• 需要配合MaterialApp.locale使用\n• 完整国际化需要arb文件和intl包'**
  String get localeUsageDetails;

  /// 重试按钮
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// 应用运行正常提示
  ///
  /// In zh, this message translates to:
  /// **'应用运行正常'**
  String get appRunningNormally;

  /// 日志级别标签
  ///
  /// In zh, this message translates to:
  /// **'日志级别'**
  String get logLevel;

  /// 全部选项
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get all;

  /// 错误级别
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get errorLevel;

  /// 警告级别
  ///
  /// In zh, this message translates to:
  /// **'警告'**
  String get warningLevel;

  /// 信息级别
  ///
  /// In zh, this message translates to:
  /// **'信息'**
  String get infoLevel;

  /// 调试级别
  ///
  /// In zh, this message translates to:
  /// **'调试'**
  String get debugLevel;

  /// 选择日期按钮
  ///
  /// In zh, this message translates to:
  /// **'选择日期'**
  String get selectDate;

  /// 清除筛选按钮
  ///
  /// In zh, this message translates to:
  /// **'清除筛选'**
  String get clearFilter;

  /// 确认清除一周前日志内容
  ///
  /// In zh, this message translates to:
  /// **'确定要清除一周前的日志吗？'**
  String get confirmClearWeekLogs;

  /// 一周前日志已清除提示
  ///
  /// In zh, this message translates to:
  /// **'一周前的日志已清除'**
  String get weekOldLogsCleared;

  /// 测试异常标题
  ///
  /// In zh, this message translates to:
  /// **'测试异常'**
  String get testException;

  /// 测试异常消息
  ///
  /// In zh, this message translates to:
  /// **'这是一个测试异常'**
  String get testExceptionMessage;

  /// 生成错误按钮
  ///
  /// In zh, this message translates to:
  /// **'生成错误'**
  String get generateError;

  /// 生成警告按钮
  ///
  /// In zh, this message translates to:
  /// **'生成警告'**
  String get generateWarning;

  /// 生成信息按钮
  ///
  /// In zh, this message translates to:
  /// **'生成信息'**
  String get generateInfo;

  /// 测试错误已生成提示
  ///
  /// In zh, this message translates to:
  /// **'测试错误已生成'**
  String get testErrorGenerated;

  /// 测试警告已生成提示
  ///
  /// In zh, this message translates to:
  /// **'测试警告已生成'**
  String get testWarningGenerated;

  /// 测试信息已生成提示
  ///
  /// In zh, this message translates to:
  /// **'测试信息已生成'**
  String get testInfoGenerated;

  /// 选择导出格式提示
  ///
  /// In zh, this message translates to:
  /// **'选择导出格式：'**
  String get selectExportFormat;

  /// 可读文本格式
  ///
  /// In zh, this message translates to:
  /// **'可读文本'**
  String get readableText;

  /// 正在导出提示
  ///
  /// In zh, this message translates to:
  /// **'正在导出...'**
  String get exporting;

  /// 日志导出主题
  ///
  /// In zh, this message translates to:
  /// **'错误日志导出'**
  String get logExportSubject;

  /// 导出失败或没有日志提示
  ///
  /// In zh, this message translates to:
  /// **'导出失败或没有日志可导出'**
  String get exportFailedOrNoLogs;

  /// 测试日志功能标题
  ///
  /// In zh, this message translates to:
  /// **'测试日志功能'**
  String get testLogFunction;

  /// 测试错误日志
  ///
  /// In zh, this message translates to:
  /// **'测试错误日志'**
  String get testErrorLog;

  /// 测试警告日志
  ///
  /// In zh, this message translates to:
  /// **'测试警告日志'**
  String get testWarningLog;

  /// 测试信息日志
  ///
  /// In zh, this message translates to:
  /// **'测试信息日志'**
  String get testInfoLog;

  /// 抛出测试异常
  ///
  /// In zh, this message translates to:
  /// **'抛出测试异常'**
  String get throwTestException;

  /// 时间标签
  ///
  /// In zh, this message translates to:
  /// **'时间'**
  String get time;

  /// 错误消息标签
  ///
  /// In zh, this message translates to:
  /// **'错误消息'**
  String get errorMessage;

  /// 日志详情分享主题
  ///
  /// In zh, this message translates to:
  /// **'错误日志详情'**
  String get logDetailSubject;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
