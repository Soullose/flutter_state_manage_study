part of 'setting_bloc.dart';

@immutable
sealed class SettingEvent extends  Equatable{
  const SettingEvent();

  @override
  List<Object> get props => [];

  @override
  String toString() {
    return 'SettingEvent{}';
  }
}
