import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFFF9292),
    surface: Color(0xFFEFDCDC),
    outline: Color(0xFFA3A5AA),
  ),

  shadowColor: Color(0xFFFFFFFF),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFD84A4A),
    surface: Color(0xFF111214),
    outline: Color(0xFF33353A),
  ),

  shadowColor: const Color(0x33000000),
);

extension ThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
}