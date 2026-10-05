import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/home/home_page.dart';
import '../ui/favorite/favorite_page.dart';
import '../ui/playlists/playlists_page.dart';
import '../ui/atrists/artists_feed.dart';
import '../ui/settings/settings_page.dart';
import '../ui/about/about_page.dart';

enum AppRoutes {
  home(name: 'home', path: '/'),
  favoritePage(name: 'favoritePage', path: '/favorite-page'),
  playlistsPage(name: 'playlistsPage', path: '/playlists-page'),
  artistsFeed(name: 'artistsFeed', path: '/artists-feed'),
  settings(name: 'settings', path: '/settings'),
  about(name: 'about', path: '/about');

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
        name: AppRoutes.favoritePage.name,
        path: AppRoutes.favoritePage.path,
        builder: (context, state) => const FavoritesPage(),
      ),

      GoRoute(
        name: AppRoutes.playlistsPage.name,
        path: AppRoutes.playlistsPage.path,
        builder: (context, state) => const PlaylistsPage(),
      ),

      GoRoute(
        name: AppRoutes.artistsFeed.name,
        path: AppRoutes.artistsFeed.path,
        builder: (context, state) => const ArtistsFeed(),
      ),

      GoRoute(
        name: AppRoutes.settings.name,
        path: AppRoutes.settings.path,
        builder: (context, state) => const SettingsPage(),
      ),

      GoRoute(
        name: AppRoutes.about.name,
        path: AppRoutes.about.path,
        builder: (context, state) => const AboutPage(),
      ),
    ],
  );
}

extension Navigation on BuildContext {
  void goRoute(AppRoutes route) => go(route.path);

  void pushRoute(AppRoutes route) => push(route.path);
}