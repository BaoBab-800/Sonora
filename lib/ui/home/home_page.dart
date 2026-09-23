import 'package:flutter/material.dart';

import 'home_drawer.dart';
import 'home_player_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Sonora'),
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },

              icon: const Icon(Icons.menu),
            );
          },
        ),
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final player = const HomePlayerSection();
            final library = const _LibrarySections();

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(flex: 5, child: HomePlayerSection()),
                      const SizedBox(width: 20),
                      const Expanded(flex: 7, child: _LibrarySections()),
                    ],
                  )
                else ...[
                  player,
                  const SizedBox(height: 20),
                  library,
                ],
                const SizedBox(height: 20),
                const _TrackFeedSection(),
              ],
            );
          },
        ),
      ),

      drawer: const HomeDrawer(),
    );
  }
}

class _LibrarySections extends StatelessWidget {
  const _LibrarySections();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _HomePlaceholderSection(
          title: 'Плейлисты',
          icon: Icons.queue_music_outlined,
          message: 'Здесь появятся ваши плейлисты.',
        ),
        SizedBox(height: 20),
        _HomePlaceholderSection(
          title: 'Исполнители',
          icon: Icons.person_outline,
          message: 'Здесь появятся исполнители из медиатеки.',
        ),
      ],
    );
  }
}

class _TrackFeedSection extends StatelessWidget {
  const _TrackFeedSection();

  @override
  Widget build(BuildContext context) {
    return const _HomePlaceholderSection(
      title: 'Треки',
      icon: Icons.library_music_outlined,
      message: 'Загрузите музыку с устройства в секции плеера.',
    );
  }
}

class _HomePlaceholderSection extends StatelessWidget {
  const _HomePlaceholderSection({
    required this.title,
    required this.icon,
    required this.message,
  });

  final String title;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 18),
            Text(message),
          ],
        ),
      ),
    );
  }
}