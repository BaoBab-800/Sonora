import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/core/providers/player_providers.dart';

import 'package:sonora/data/player_controller/track.dart';

import 'package:sonora/services/player_controller/i_player_controller.dart';
import 'package:sonora/services/player_manager/player_manager.dart';

Future<void> playTrack(WidgetRef ref, List<Track> tracks, int index) async {
  final manager = ref.read(playerManagerProvider);
  final playerId = ref.read(selectedPlayerIdProvider);

  final player = getPlayer(ref, manager, playerId);

  await player.setQueue(tracks);
  await player.skipTo(index);
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
