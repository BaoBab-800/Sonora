import 'package:flutter/material.dart';

class Settings {
  final ThemeMode themeMode;
  final Locale locale;

  const Settings({
    required this.themeMode,
    required this.locale,
  });

  Settings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}