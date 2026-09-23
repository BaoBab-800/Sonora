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
      primary: Color(0xFFD84A4A),
    ),

    surfaces: AppSurfaceColors(
      surface: Color(0xFF111214),
    ),
  ),
);

extension ThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
}