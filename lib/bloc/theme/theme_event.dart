part of 'theme_bloc.dart';

@immutable
sealed class ThemeEvent {}

class ToggleDark extends ThemeEvent {}

class ToggleLight extends ThemeEvent {}
