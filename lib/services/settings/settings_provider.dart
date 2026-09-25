import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/core/providers/storage_providers.dart';
import 'package:sonora/data/settings/settings_model.dart';

class SettingsProvider extends AsyncNotifier<Settings> {
  static const _themeKey = 'themeMode';
  static const _localeKey = 'locale';

  @override
  Future<Settings> build() async {
    final storage = ref.watch(storageProvider);

    final themeIndex = await storage.get<int>(_themeKey) ?? 0;
    final localeCode = await storage.get<String>(_localeKey) ?? 'en';

    return Settings(
      themeMode: ThemeMode.values[themeIndex],
      locale: Locale(localeCode),
    );
  }

  Future<void> changeTheme(ThemeMode mode) async {
    final storage = ref.read(storageProvider);

    await update((settings) async {
      await storage.put<int>(_themeKey, mode.index);

      return settings.copyWith(
        themeMode: mode,
      );
    });
  }

  Future<void> changeLocale(String code) async {
    final storage = ref.read(storageProvider);

    await update((settings) async {
      await storage.put<String>(_localeKey, code);

      return settings.copyWith(
        locale: Locale(code),
      );
    });
  }
}