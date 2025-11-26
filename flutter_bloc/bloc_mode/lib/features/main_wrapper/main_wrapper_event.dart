part of 'main_wrapper_bloc.dart';

sealed class MainWrapperEvent extends Equatable {
  const MainWrapperEvent();

  @override
  List<Object> get props {
    return [];
  }


}

class InitIndexPage extends MainWrapperEvent {}

class ChangeIndexPage extends MainWrapperEvent {
  final int index;

  const ChangeIndexPage(this.index);

  @override
  List<Object> get props {
    debugPrint(index.toString());
    return [index];
  }
  // const ChangeIndexPage();
}