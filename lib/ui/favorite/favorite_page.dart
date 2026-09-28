import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/core/l10n/l10n.dart';
import 'package:sonora/core/theme/theme.dart';
import 'package:sonora/core/providers/favorite_providers.dart';

import '../playlists/playlist_detail_page.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(favoriteTracksProvider);

    return Scaffold(
      body: tracks.isEmpty
          ? const _EmptyFavorites()
          : CustomScrollView(
        slivers: [
          PlaylistHeader(
            name: context.l10n.favorite,
            trackCount: tracks.length,
            icon: Icon(
              Icons.favorite,
              size: 48,
              color: context.colors.primary,
            ),
          ),

          SliverList.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: PlaylistTrackTile(
                  key: ValueKey(track.id),
                  track: track,
                  index: index,
                  showIndex: false,
                  tracks: tracks,
                  onDismissed: () {
                    ref.read(favoritesRepositoryProvider).toggle(track.id);
                  },
                ),
              );
            },
          ),
        ],
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
          Text(context.l10n.noFavoriteTracks),
        ],
      ),
    );
  }
}