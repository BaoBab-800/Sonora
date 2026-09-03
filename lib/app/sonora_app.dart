import 'package:flutter/material.dart';

import 'app_router.dart';
import 'package:sonora/core/theme/theme.dart';
import 'package:sonora/core/l10n/l10n.dart';

class SonoraApp extends StatelessWidget {
  const SonoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sonora',

      theme: theme.light,
      darkTheme: theme.dark,
      themeMode: ThemeMode.dark,

      locale: L10n.defaultLocale,
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: L10n.localizationsDelegates,

      routerConfig: AppRouter.router,
    );
  }
}