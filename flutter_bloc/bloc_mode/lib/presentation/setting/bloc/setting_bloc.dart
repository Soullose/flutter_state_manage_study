import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'setting_event.dart';
part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  SettingBloc() : super(SettingInitial('127.0.0.1', '8080')) {
    on<SettingEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
