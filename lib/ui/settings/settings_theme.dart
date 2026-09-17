import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/core/l10n/l10n.dart';
import 'package:sonora/core/providers/providers.dart';

class SettingsTheme extends ConsumerWidget {
  const SettingsTheme({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Column(
      children: [
        Text(context.l10n.theme),

        settings.when(
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('$error'),
          data: (settings) {
            return RadioGroup<ThemeMode>(
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value == null) return;
                notifier.changeTheme(value);
              },

              child: Column(
                children: [
                  for (final theme in ThemeMode.values)
                    RadioListTile<ThemeMode>(
                      dense: true,
                      title: Text(theme.label(context.l10n)),
                      value: theme,
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
