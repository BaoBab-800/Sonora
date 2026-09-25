import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/core/l10n/l10n.dart';
import 'package:sonora/core/providers/playlist_providers.dart';
import 'package:sonora/core/theme/theme.dart';

import 'package:sonora/data/playlists/playlist_model.dart';

import 'create_playlist_dialog.dart';

class PlaylistsPage extends ConsumerWidget {
  const PlaylistsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.playlists)),

      body: playlistsAsync.when(
        data: (playlists) {
          if (playlists.isEmpty) {
            return Center(child: Text(context.l10n.noPlaylistsYet));
          }

          return ListView.builder(
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return _PlaylistTile(playlist: playlist);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('$error')),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const CreatePlaylistDialog(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PlaylistTile extends ConsumerWidget {
  final Playlist playlist;
  const _PlaylistTile({required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Row(
        children: [
          Text(playlist.name),
          const SizedBox(width: 6),
          Icon(Icons.circle, color: context.colors.outline, size: 8),
          const SizedBox(width: 6),
          Text('${playlist.trackIds.length}'),
        ],
      ),

      trailing: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.more_vert),
      ),
      onTap: () {
        // навигация на экран плейлиста, playlist.id
      },
    );
  }
}