import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/home/home_page.dart';
import '../ui/playlists/playlists_page.dart';
import '../ui/settings/settings_page.dart';

enum AppRoutes {
  home(name: 'home', path: '/'),
  playlistsPage(name: 'playlistsPage', path: '/playlists-page'),
  settings(name: 'settings', path: '/settings');

  final String name;
  final String path;

  const AppRoutes({
    required this.name,
    required this.path,
  });
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.home.path,
    routes: [
      GoRoute(
        name: AppRoutes.home.name,
        path: AppRoutes.home.path,
        builder: (context, state) => const HomePage(),
      ),

      GoRoute(
        name: AppRoutes.playlistsPage.name,
        path: AppRoutes.playlistsPage.path,
        builder: (context, state) => const PlaylistsPage(),
      ),

      GoRoute(
        name: AppRoutes.settings.name,
        path: AppRoutes.settings.path,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}

extension Navigation on BuildContext {
  void goRoute(AppRoutes route) => go(route.path);

  void pushRoute(AppRoutes route) => push(route.path);
}