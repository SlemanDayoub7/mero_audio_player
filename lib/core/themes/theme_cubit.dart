import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../themes/light_theme.dart';
import '../themes/dark_theme.dart';

// Event Enum
enum ThemeEvent { light, dark }

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(LightTheme.theme); // Default theme is light

  // Method to change the theme
  void toggleTheme(ThemeEvent themeEvent) {
    if (themeEvent == ThemeEvent.light) {
      emit(LightTheme.theme);
    } else {
      emit(DarkTheme.theme);
    }
  }
}
