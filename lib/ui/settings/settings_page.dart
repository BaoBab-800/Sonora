import 'package:flutter/material.dart';

import 'settings_locale.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),

      body: ListView(
        children: [
          SettingsLocale(),
        ],
      ),
    );
  }
}