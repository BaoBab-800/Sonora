import 'package:flutter/material.dart';

import 'app_router.dart';
import 'package:sonora/core/theme/theme.dart';

class SonoraApp extends StatelessWidget {
  const SonoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sonora',

      theme: theme.light,
      darkTheme: theme.dark,
      themeMode: ThemeMode.dark,

      routerConfig: AppRouter.router,
    );
  }
}