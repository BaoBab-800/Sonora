import 'package:flutter/material.dart';

import 'package:sonora/core/l10n/l10n.dart';
import 'package:sonora/core/theme/theme.dart';
import 'package:sonora/ui/settings/settings_theme.dart';

import 'settings_locale.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.settings,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: ListView(
        children: [
          Divider(color: context.colors.outline),
          const SettingsTheme(),
          const SettingsLocale(),
        ],
      ),
    );
  }
}