import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/core/l10n/l10n.dart';
import 'package:sonora/core/providers/favorite_providers.dart';

import 'package:sonora/data/player_controller/track.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(favoriteTracksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),

      body: tracks.isEmpty
          ? const _EmptyFavorites()
          : ListView.builder(
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final track = tracks[index];

          return _FavoriteTrackTile(
            key: ValueKey(track.id),
            track: track,
          );
        },
      ),
    );
  }
}

class _FavoriteTrackTile extends ConsumerWidget {
  const _FavoriteTrackTile({
    super.key,
    required this.track,
  });

  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(track.id),
      direction: DismissDirection.endToStart,
      background: const SizedBox.shrink(),
      secondaryBackground: _DeleteBackground(),
      onDismissed: (_) => ref.read(favoritesRepositoryProvider).toggle(track.id),

      child: ListTile(
        leading: const Icon(Icons.music_note),
        title: Text(track.title),
        subtitle: Text(track.artist ?? context.l10n.unknownArtist),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.red,
      child: const Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),

          const SizedBox(height: 16),
          const Text('No favorite tracks'),
        ],
      ),
    );
  }
}