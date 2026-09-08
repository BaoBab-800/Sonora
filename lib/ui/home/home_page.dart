import 'package:flutter/material.dart';

import 'package:sonora/app/app_router.dart';

import 'package:sonora/core/l10n/l10n.dart';
import 'package:sonora/core/theme/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,

      appBar: AppBar(
        title: Text(
          'Sonora',
        ),

        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },

              icon: Icon(
                Icons.menu
              ),
            );
          }
        ),
      ),

      body: Center(
        child: Card(
          color: context.colors.primary,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(context.l10n.denchik),
          ),
        ),
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text(context.l10n.settings),
              onTap: () {
                Navigator.pop(context);
                Navigation(context).pushRoute(AppRoutes.settings);
              },
            ),
          ],
        ),
      ),
    );
  }
}