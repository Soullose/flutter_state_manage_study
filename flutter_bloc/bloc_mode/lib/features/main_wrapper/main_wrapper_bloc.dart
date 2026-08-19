import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cupertino_ui/cupertino_ui.dart';

part 'main_wrapper_event.dart';
part 'main_wrapper_state.dart';

class MainWrapperBloc extends Bloc<MainWrapperEvent, MainWrapperState> {
  MainWrapperBloc() : super(const MainWrapperInitial()) {
    on<InitIndexPage>(_initIndexPage);
    on<ChangeIndexPage>(_changeIndexPage);
  }

  void _initIndexPage(InitIndexPage event, Emitter<MainWrapperState> emit) {
    emit(const MainWrapperInitial());
  }

  void _changeIndexPage(ChangeIndexPage event, Emitter<MainWrapperState> emit) {
    emit(MainWrapperChange(event.index));
  }
}
