import 'package:flutter/material.dart';
import 'package:app_foundation/app_foundation.dart';

const theme = AppTheme(
  lightPalette: AppPalette(
    brand: AppBrandColors(
      primary: Colors.blue,
    ),

    surfaces: AppSurfaceColors(
      surface: Color(0xFF0C0C16),
    ),
  ),

  darkPalette: AppPalette(
    brand: AppBrandColors(
      primary: Colors.blue,
    ),

    surfaces: AppSurfaceColors(
      surface: Color(0xFF0C0C16),
    ),
  ),
);

extension ThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
}