import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'setting_event.dart';

part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  SettingBloc() : super(const SettingInitial('127.0.0.1', '8080')) {
    on<SettingEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<SettingChangeEvent>(_onSettingChangeEvent);
  }

  void _onSettingChangeEvent(
      SettingChangeEvent event, Emitter<SettingState> emit) {
    emit(SettingInProgress(event.ipAddress, event.port));
  }
}
