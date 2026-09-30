import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/core/l10n/l10n.dart';
import 'package:sonora/core/theme/theme.dart';
import 'package:sonora/core/providers/artists_provider.dart';

import '../playlists/playlist_detail_page.dart';
import '../playlists/player_supporter.dart';

class ArtistPlaylist extends ConsumerWidget {
  final String artistKey;
  const ArtistPlaylist({super.key, required this.artistKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artist = ref.watch(artistProvider(artistKey));
    final tracks = ref.watch(artistTracksProvider(artistKey));
    final theme = Theme.of(context);

    final name = artist?.name ?? '';
    final initial = artist == null || artist.isUnknown || name.isEmpty
        ? '?'
        : String.fromCharCode(name.runes.first).toUpperCase();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(pinned: true),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 64,
                    backgroundColor: context.colors.primaryContainer,
                    child: Text(
                      initial,
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: context.colors.onPrimaryContainer,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    _tracksLabel(context, tracks.length),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: tracks.isEmpty
                              ? null
                              : () => playTrack(ref, tracks, 0),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(context.l10n.play),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: tracks.isEmpty
                              ? null
                              : () => playTrack(ref, List.of(tracks)..shuffle(), 0),
                          icon: const Icon(Icons.shuffle_rounded),
                          label: Text(context.l10n.mix),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final track = tracks[index];
                return Padding(
                  key: ValueKey(track.id),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: PlaylistTrackTile(
                    track: track,
                    index: index,
                    showIndex: false,
                    tracks: tracks,
                  ),
                );
              },
              childCount: tracks.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }

  String _tracksLabel(BuildContext context, int n) {
    final mod10 = n % 10, mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return '$n ${context.l10n.track.toLowerCase()}';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return '$n ${context.l10n.tracks.toLowerCase()}';
    return '$n ${context.l10n.tracksL.toLowerCase()}';
  }
}