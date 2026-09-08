import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/core/l10n/l10n.dart';
import 'package:sonora/core/providers/storage_provider.dart';

class SettingsLocale extends ConsumerWidget {
  const SettingsLocale({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Column(
      children: [
        Text(context.l10n.language),

        settings.when(
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('$error'),
          data: (settings) {
            return RadioGroup<Locale>(
              groupValue: settings.locale,
              onChanged: (value) {
                if (value == null) return;
                notifier.changeLocale(value.languageCode);
              },

              child: Column(
                children: [
                  for (final language in L10n.supportedLocales)
                    RadioListTile<Locale>(
                      dense: true,
                      title: Text(language.languageCode.toUpperCase()),
                      value: language,
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