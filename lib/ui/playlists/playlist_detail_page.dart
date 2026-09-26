import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          appBar: AppBar(title: Text(playlist.name)),
          body: tracks.isEmpty
              ? Center(child: Text(context.l10n.playlistIsEmpty))
              : ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              return ListTile(
                leading: Text('${index + 1}'),

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
          ),
        );
      },

      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('$error'))),
    );
  }
}