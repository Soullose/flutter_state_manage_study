part of 'setting_bloc.dart';

@immutable
sealed class SettingState extends Equatable {
  const SettingState(this.ipAddress, this.port);

  final String ipAddress;

  final String port;

  @override
  List<Object> get props => [ipAddress, port];

  @override
  String toString() {
    return 'SettingState{props: $props}';
  }
}

final class SettingInitial extends SettingState {
  const SettingInitial(super.ipAddress, super.port);

  @override
  List<Object> get props => [ipAddress, port];

  @override
  String toString() {
    return 'SettingInitial{props: $props}';
  }
}

final class SettingInProgress extends SettingState {
  const SettingInProgress(super.ipAddress, super.port);

  @override
  List<Object> get props => [ipAddress, port];

  @override
  String toString() {
    return 'SettingInProgress{props: $props}';
  }
}
