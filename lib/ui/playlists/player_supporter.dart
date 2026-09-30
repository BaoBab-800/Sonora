import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/core/providers/player_providers.dart';

import 'package:sonora/data/player_controller/controller_state.dart';
import 'package:sonora/data/player_engine/player_status.dart';
import 'package:sonora/data/player_controller/track.dart';

import 'package:sonora/services/player_controller/i_player_controller.dart';
import 'package:sonora/services/player_manager/player_manager.dart';

Future<void> playTrack(WidgetRef ref, List<Track> tracks, int index) async {
  final manager = ref.read(playerManagerProvider);
  final playerId = ref.read(selectedPlayerIdProvider);

  final player = getPlayer(ref, manager, playerId);

  await player.setQueue(tracks, startIndex: index);
  await player.play();
}

bool hasQueue(ControllerState? state, List<Track> tracks) {
  final queue = state?.queue;
  if (queue == null || queue.length != tracks.length) return false;

  for (var index = 0; index < tracks.length; index++) {
    if (queue[index].id != tracks[index].id) return false;
  }

  return true;
}

Future<void> toggleQueuePlayback(
    WidgetRef ref,
    List<Track> tracks, {
      int index = 0,
    }) async {
  final manager = ref.read(playerManagerProvider);
  final playerId = ref.read(selectedPlayerIdProvider);
  final player = getPlayer(ref, manager, playerId);

  if (hasQueue(player.state, tracks)) {
    if (player.state.status == PlayerStatus.playing) {
      await player.pause();
    } else {
      await player.play();
    }
    return;
  }

  await player.setQueue(tracks, startIndex: index);
  await player.play();
}

IPlayerController getPlayer(
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
