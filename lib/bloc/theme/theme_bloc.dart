import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(LightTheme()) {
    on<ToggleDark>(_onToggleDark);
    on<ToggleLight>(_onToggleLight);
  }
  void _onToggleDark(ToggleDark event, Emitter<ThemeState> emit) {
    emit(DarkTheme());
  }

  void _onToggleLight(ToggleLight event, Emitter<ThemeState> emit) {
    emit(LightTheme());
  }
}
