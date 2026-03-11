part of 'locale_bloc.dart';

/// 多语言事件基类
sealed class LocaleEvent extends Equatable {
  const LocaleEvent();

  @override
  List<Object> get props => [];
}

/// 切换语言事件（中/英切换）
class LocaleToggled extends LocaleEvent {
  const LocaleToggled();
}

/// 设置指定语言
class LocaleChanged extends LocaleEvent {
  final Locale locale;

  const LocaleChanged(this.locale);

  @override
  List<Object> get props => [locale];
}

/// 从存储加载语言设置
class LocaleLoadedFromStorage extends LocaleEvent {
  const LocaleLoadedFromStorage();
}
