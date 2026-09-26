import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/core/l10n/l10n.dart';
import 'package:sonora/core/providers/playlist_providers.dart';

import 'package:sonora/data/player_controller/track.dart';
import 'package:sonora/data/playlists/playlist_model.dart';

import 'create_playlist_dialog.dart';

class AddToPlaylistSheet extends ConsumerWidget {
  final Track track;
  const AddToPlaylistSheet({super.key, required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsStreamProvider);

    return SafeArea(
      child: playlistsAsync.when(
        data: (playlists) => ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: Text(context.l10n.newPlaylist),
              onTap: () async {
                Navigator.pop(context);
                await showDialog(
                  context: context,
                  builder: (_) => CreatePlaylistDialog(initialTrack: track),
                );
              },
            ),
            const Divider(height: 1),
            for (final playlist in playlists)
              _PlaylistCheckTile(playlist: playlist, track: track),
          ],
        ),
        loading: () => const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('$error'),
        ),
      ),
    );
  }
}

class _PlaylistCheckTile extends ConsumerWidget {
  final Playlist playlist;
  final Track track;
  const _PlaylistCheckTile({required this.playlist, required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInPlaylist = playlist.trackIds.contains(track.id);

    return CheckboxListTile(
      title: Text(playlist.name),
      value: isInPlaylist,
      onChanged: (_) {
        final controller = ref.read(playlistControllerProvider);
        if (isInPlaylist) {
          controller.removeTrack(playlist.id, track.id);
        } else {
          controller.addTrack(playlist.id, track.id);
        }
      },
    );
  }
}