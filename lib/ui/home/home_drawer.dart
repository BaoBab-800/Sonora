import 'package:flutter/material.dart';

import 'package:sonora/app/app_router.dart';

import 'package:sonora/core/l10n/l10n.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: Text(context.l10n.settings),
            onTap: () {
              Navigator.pop(context);
              Navigation(context).pushRoute(AppRoutes.settings);
            },
          ),

          ListTile(
            title: Text('Test player'),
            onTap: () {
              Navigator.pop(context);
              Navigation(context).pushRoute(AppRoutes.testPlayer);
            },
          ),
        ],
      ),
    );
  }
}