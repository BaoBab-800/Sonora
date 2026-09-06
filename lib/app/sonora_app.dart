import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';

import 'package:sonora/core/theme/theme.dart';
import 'package:sonora/core/l10n/l10n.dart';
import 'package:sonora/core/providers/storage_provider.dart';

class SonoraApp extends ConsumerWidget {
  const SonoraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsService);

    return settings.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('$error'),
      data: (settings) {
        return MaterialApp.router(
          title: 'Sonora',

          theme: theme.light,
          darkTheme: theme.dark,
          themeMode: ThemeMode.dark,

          locale: settings.locale,
          supportedLocales: L10n.supportedLocales,
          localizationsDelegates: L10n.localizationsDelegates,

          routerConfig: AppRouter.router,
        );
      },
    );
  }
}