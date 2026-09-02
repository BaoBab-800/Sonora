import 'package:flutter/material.dart';
import 'package:app_foundation/app_foundation.dart';

import 'app_router.dart';

class SonoraApp extends StatelessWidget {
  const SonoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme();

    return MaterialApp.router(
      title: 'Sonora',

      theme: appTheme.light,
      darkTheme: appTheme.dark,
      themeMode: ThemeMode.dark,

      routerConfig: AppRouter.router,
    );
  }
}
