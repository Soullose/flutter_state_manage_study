part of 'theme_bloc.dart';

@immutable
sealed class ThemeState {
  const ThemeState();
}

final class ThemeInitial extends ThemeState {

}

final class ThemeChange extends ThemeState {}
