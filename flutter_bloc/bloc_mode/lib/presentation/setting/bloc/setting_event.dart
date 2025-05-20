part of 'setting_bloc.dart';

@immutable
sealed class SettingEvent extends Equatable {
  const SettingEvent();

  @override
  List<Object> get props => [];

  @override
  String toString() {
    return 'SettingEvent{}';
  }
}

final class SettingChangeEvent extends SettingEvent {
  final String ipAddress;
  final String port;

  const SettingChangeEvent(this.ipAddress, this.port);

  @override
  List<Object> get props => [ipAddress, port];

  @override
  String toString() {
    return 'SettingChangeEvent{ipAddress: $ipAddress, port: $port}';
  }
}
