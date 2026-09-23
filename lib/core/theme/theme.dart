import 'package:flutter/material.dart';
import 'package:app_foundation/app_foundation.dart';

const theme = AppTheme(
  lightPalette: AppPalette(
    brand: AppBrandColors(
      primary: Color(0xFFFF9292),
    ),

    surfaces: AppSurfaceColors(
      surface: Color(0xFFEFDCDC),
    ),
  ),

  darkPalette: AppPalette(
    brand: AppBrandColors(
      primary: Color(0xFFB34242),
    ),

    surfaces: AppSurfaceColors(
      surface: Color(0xFF100C0C),
    ),
  ),
);

extension ThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
}