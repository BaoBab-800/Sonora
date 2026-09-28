import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/core/theme/theme.dart';
import 'package:sonora/core/l10n/l10n.dart';
import 'package:sonora/core/providers/playlist_providers.dart';
import 'package:sonora/core/providers/player_providers.dart';
import 'package:sonora/core/providers/track_providers.dart';

import 'package:sonora/data/player_controller/track.dart';

import 'package:sonora/services/player_controller/i_player_controller.dart';
import 'package:sonora/services/player_manager/player_manager.dart';

class PlaylistDetailPage extends ConsumerWidget {
  final String playlistId;

  const PlaylistDetailPage({
    super.key,
    required this.playlistId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistAsync = ref.watch(playlistByIdProvider(playlistId));

    return playlistAsync.when(
      data: (playlist) {
        if (playlist == null) {
          return const _PlaylistNotFound();
        }

        return _PlaylistDetailView(playlist: playlist);
      },
      loading: () => const _LoadingView(),
      error: (error, stack) => _ErrorView(error: error),
    );
  }
}

class _PlaylistDetailView extends ConsumerWidget {
  final PlaylistSnapshot playlist;

  const _PlaylistDetailView({
    required this.playlist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackRepo = ref.watch(trackRepositoryProvider);

    final tracks = playlist.trackIds
        .map(trackRepo.getById)
        .whereType<Track>()
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          PlaylistHeader(
            name: playlist.name,
            trackCount: tracks.length,
            icon: Icon(
              Icons.queue_music,
              size: 48,
              color: context.colors.onPrimaryContainer,
            ),
          ),

          _PlaylistTrackList(
            playlistId: playlist.id,
            tracks: tracks,
          ),
        ],
      ),
    );
  }
}

class PlaylistHeader extends StatelessWidget {
  final String name;
  final int trackCount;
  final Widget icon;

  const PlaylistHeader({
    super.key,
    required this.name,
    required this.trackCount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SliverAppBar(
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
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
                colors.primaryContainer,
                colors.surface,
              ],
            ),
          ),

          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 26),
                icon,

                const SizedBox(height: 8),
                Text(
                  context.l10n.numberOfTracks(trackCount),
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaylistTrackList extends ConsumerWidget {
  final String playlistId;
  final List<Track> tracks;

  const _PlaylistTrackList({
    required this.playlistId,
    required this.tracks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tracks.isEmpty) {
      return const _EmptyPlaylist();
    }

    return SliverReorderableList(
      itemCount: tracks.length,
      proxyDecorator: (child, index, animation) {
        return Material(
          elevation: 6,
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          child: child,
        );
      },

      onReorderItem: (oldIndex, newIndex) {
        final adjustedIndex =
        newIndex > oldIndex ? newIndex - 1 : newIndex;

        ref.read(playlistControllerProvider).reorderTrack(
          playlistId,
          oldIndex,
          adjustedIndex,
        );
      },

      itemBuilder: (context, index) {
        final track = tracks[index];

        return PlaylistTrackTile(
          key: ValueKey(track.id),
          track: track,
          index: index,
          showIndex: true,
          tracks: tracks,
          trailing: ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle),
          ),
          onDismissed: () {
            ref.read(playlistControllerProvider).removeTrack(
              playlistId,
              track.id,
            );
          },
        );
      },
    );
  }
}

class PlaylistTrackTile extends ConsumerWidget {
  final Track track;
  final int index;
  final bool showIndex;
  final List<Track> tracks;
  final VoidCallback onDismissed;
  final Widget? trailing;

  const PlaylistTrackTile({
    super.key,
    required this.track,
    required this.index,
    required this.showIndex,
    required this.tracks,
    required this.onDismissed,
    this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(track.id),
      direction: DismissDirection.endToStart,
      background: const _DeleteBackground(),
      onDismissed: (_) => onDismissed,

      child: ListTile(
        leading: showIndex
            ? SizedBox(
          width: 32,
          child: Text(
            '${index + 1}',
            textAlign: TextAlign.center,
          ),
        ) : null,

        title: Text(
          track.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            track.artist ?? context.l10n.unknownArtist,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),

        trailing: trailing,
        onTap: () => _playTrack(ref),
      ),
    );
  }

  Future<void> _playTrack(WidgetRef ref) async {
    final manager = ref.read(playerManagerProvider);
    final playerId = ref.read(selectedPlayerIdProvider);

    final player = _getPlayer(ref, manager, playerId);

    await player.setQueue(tracks);
    await player.skipTo(index);
  }

  IPlayerController _getPlayer(
      WidgetRef ref,
      PlayerManager manager,
      String? playerId,
      ) {
    if (playerId == null) {
      final player = manager.createPlayer();

      ref.read(selectedPlayerIdProvider.notifier).state = player.id;

      return player;
    }

    final existingPlayer = manager.getPlayer(playerId);

    if (existingPlayer != null) {
      return existingPlayer;
    }

    final player = manager.createPlayer();

    ref.read(selectedPlayerIdProvider.notifier).state = player.id;

    return player;
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }
}

class _EmptyPlaylist extends StatelessWidget {
  const _EmptyPlaylist();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Text(context.l10n.playlistIsEmpty),
      ),
    );
  }
}

class _PlaylistNotFound extends StatelessWidget {
  const _PlaylistNotFound();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(context.l10n.playlistNotFound),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;

  const _ErrorView({
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('$error'),
      ),
    );
  }
}