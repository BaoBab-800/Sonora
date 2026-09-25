import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/data/player_controller/controller_state.dart';

import 'package:sonora/services/player_manager/player_manager.dart';
import 'package:sonora/services/player_controller/i_player_controller.dart';
import 'package:sonora/services/player_controller/player_controller.dart';
import 'package:sonora/services/playback_engine/playback_engine.dart';

final playerManagerProvider = Provider<PlayerManager>((ref) {
  final manager = PlayerManager(
    controllerFactory: (id) => PlayerController(
      id: id,
      engine: PlaybackEngine(),
    ),
  );
  ref.onDispose(() {
    manager.dispose();
  });
  return manager;
});

final aggregatedPlayerStatesProvider = StreamProvider<Map<String, ControllerState>>((ref) {
  final manager = ref.watch(playerManagerProvider);
  return manager.stateStream;
});

final playerIdsProvider = Provider<List<String>>((ref) {
  final states = ref.watch(aggregatedPlayerStatesProvider).value;
  return states?.keys.toList() ?? const [];
});

final playerControllerProvider = Provider.family<IPlayerController?, String>((ref, id) {
  return ref.watch(playerManagerProvider).getPlayer(id);
});

final controllerStateProvider = StreamProvider.family<ControllerState, String>((ref, id) {
  final controller = ref.watch(playerControllerProvider(id));
  if (controller == null) {
    return const Stream.empty();
  }
  return controller.stateStream;
});