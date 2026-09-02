import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:sonora/ui/home/home_page.dart';

enum AppRoutes {
  home(name: 'home', path: '/');

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
    ],
  );
}

extension Navigation on BuildContext {
  void goRoute(AppRoutes route) => go(route.path);

  void pushRoute(AppRoutes route) => push(route.path);
}