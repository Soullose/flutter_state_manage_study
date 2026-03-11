part of 'locale_bloc.dart';

/// 多语言状态类
class LocaleState extends Equatable {
  final Locale locale;

  /// 支持的语言列表
  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ];

  const LocaleState({this.locale = const Locale('zh', 'CN')});

  /// 是否为中文
  bool get isChinese => locale.languageCode == 'zh';

  /// 是否为英文
  bool get isEnglish => locale.languageCode == 'en';

  LocaleState copyWith({Locale? locale}) {
    return LocaleState(locale: locale ?? this.locale);
  }

  @override
  List<Object> get props => [locale];

  @override
  String toString() => 'LocaleState(locale: $locale)';
}
