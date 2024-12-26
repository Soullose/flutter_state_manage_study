part of 'main_wrapper_bloc.dart';

sealed class MainWrapperState extends Equatable {
  const MainWrapperState._({
    this.indexPage = 0,
  });

  static const MainWrapperInitial _instance = MainWrapperInitial();

  factory MainWrapperState() => _instance;

  final int indexPage;
}

final class MainWrapperInitial extends MainWrapperState {
  const MainWrapperInitial() : super._();

  @override
  List<Object> get props => [indexPage];
}

final class MainWrapperChange extends MainWrapperState {
  const MainWrapperChange(index) : super._(indexPage: index);

  @override
  // TODO: implement props
  List<Object?> get props => [indexPage];
}