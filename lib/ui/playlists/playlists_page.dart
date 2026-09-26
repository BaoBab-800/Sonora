import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/core/theme/theme.dart';
import 'package:sonora/core/l10n/l10n.dart';
import 'package:sonora/core/providers/playlist_providers.dart';

import 'package:sonora/data/playlists/playlist_model.dart';
import 'package:sonora/data/playlists/playlist_actions.dart';

import 'create_playlist_dialog.dart';
import 'edit_playlist_name_dialog.dart';
import 'playlist_detail_page.dart';

class PlaylistsPage extends ConsumerWidget {
  const PlaylistsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.playlists,
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: context.colors.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.queue_music,
          color: context.colors.onPrimaryContainer,
        ),
      ),

      title: Text(
        playlist.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),

      subtitle: Text(
        context.l10n.numberOfTracks(playlist.trackIds.length),
        style: TextStyle(
          color: Colors.grey,
        ),
      ),

      trailing: PopupMenuButton<PlaylistActions>(
        onSelected: (action) => _handleAction(context, ref, action),

        itemBuilder: (context) {
          return [
            PopupMenuItem(
              value: PlaylistActions.editName,
              child: Text(context.l10n.editName),
            ),

            PopupMenuItem(
              value: PlaylistActions.moveUp,
              child: Text(context.l10n.moveUp),
            ),

            PopupMenuItem(
              value: PlaylistActions.moveDown,
              child: Text(context.l10n.moveDown),
            ),

            PopupMenuItem(
              value: PlaylistActions.delete,
              child: Text(context.l10n.delete),
            ),
          ];
        },
      ),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlaylistDetailPage(playlistId: playlist.id)),
        );
      },
    );
  }

  Future<void> _handleAction(
      BuildContext context,
      WidgetRef ref,
      PlaylistActions action,
      ) async {
    switch (action) {
      case PlaylistActions.delete:
        await _deletePlaylist(context, ref);
      case PlaylistActions.editName:
        await _editPlaylistName(context, ref);
      case PlaylistActions.moveUp:
        await ref.read(playlistControllerProvider).movePlaylist(playlist.id, up: true);
      case PlaylistActions.moveDown:
        await ref.read(playlistControllerProvider).movePlaylist(playlist.id, up: false);
    }
  }

  Future<void> _deletePlaylist(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.deletePlaylistTitle),
        content: Text(context.l10n.deletePlaylistConfirm(playlist.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.close),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(playlistControllerProvider).deletePlaylist(playlist.id);
    }
  }

  Future<void> _editPlaylistName(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (_) => EditPlaylistNameDialog(playlist: playlist),
    );
  }
}