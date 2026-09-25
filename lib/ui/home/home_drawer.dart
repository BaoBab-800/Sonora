import 'package:flutter/material.dart';

import 'package:sonora/app/app_router.dart';

import 'package:sonora/core/l10n/l10n.dart';
import 'package:sonora/core/theme/theme.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Material(
            elevation: 2.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              color: context.colors.primary,
              child: Text(
                context.l10n.menu,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          _DrawerCard(
            title: context.l10n.settings,
            icon: Icons.settings,
            route: AppRoutes.settings,
          ),
        ],
      ),
    );
  }
}

class _DrawerCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final AppRoutes route;

  const _DrawerCard({
    required this.title,
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),

      leading: Icon(icon),

      onTap: () {
        Navigator.pop(context);
        Navigation(context).pushRoute(route);
      },
    );
  }
}