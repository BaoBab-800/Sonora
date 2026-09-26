import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/core/theme/theme.dart';
import 'package:sonora/core/l10n/l10n.dart';
import 'package:sonora/core/providers/playlist_providers.dart';
import 'package:sonora/core/providers/player_providers.dart';

import 'package:sonora/services/player_controller/i_player_controller.dart';

class PlaylistDetailPage extends ConsumerWidget {
  final String playlistId;
  const PlaylistDetailPage({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistAsync = ref.watch(playlistByIdProvider(playlistId));

    return playlistAsync.when(
      data: (playlist) {
        if (playlist == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(context.l10n.playlistNotFound)),
          );
        }

        final tracks = ref.watch(playlistTracksProvider(playlist));

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(
                  playlist.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),

                pinned: true,
                expandedHeight: 160,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.surface,
                        ],
                      ),
                    ),

                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.queue_music, size: 48, color: context.colors.onPrimaryContainer),
                          const SizedBox(height: 8),
                          Text(
                            context.l10n.numberOfTracks(tracks.length),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              if (tracks.isEmpty)
                SliverFillRemaining(
                  child: Center(child: Text(context.l10n.playlistIsEmpty)),
                )
                else SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final track = tracks[index];
                  return ListTile(
                    leading: SizedBox(
                      width: 32,
                      child: Text(
                        '${index + 1}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),

                    title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(track.artist ?? context.l10n.unknownArtist),

                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => ref
                          .read(playlistControllerProvider)
                          .removeTrack(playlist.id, track.id),
                    ),

                    onTap: () async {
                      final manager = ref.read(playerManagerProvider);
                      var playerId = ref.read(selectedPlayerIdProvider);

                      IPlayerController? player;
                      if (playerId == null) {
                        player = manager.createPlayer();
                        ref.read(selectedPlayerIdProvider.notifier).state = player.id;
                      } else {
                        player = manager.getPlayer(playerId);
                        player ??= manager.createPlayer();
                      }

                      await player.setQueue(tracks);
                      await player.skipTo(index);
                    },
                  );
                },
                  childCount: tracks.length,
                ),
              ),
            ],
          ),
        );
      },

      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('$error'))),
    );
  }
}