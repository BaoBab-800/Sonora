import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/app/app_bootstrap.dart' as bootstrap;

import 'package:sonora/data/settings/settings_model.dart';
import 'package:sonora/data/player_controller/controller_state.dart';
import 'package:sonora/data/player_controller/track.dart';

import 'package:sonora/services/storage/i_key_value_storage.dart';
import 'package:sonora/services/storage/hive_key_value_storage.dart';

import 'package:sonora/services/settings/settings_provider.dart';

import 'package:sonora/services/player_manager/player_manager.dart';

import 'package:sonora/services/player_controller/i_player_controller.dart';
import 'package:sonora/services/player_controller/player_controller.dart';

import 'package:sonora/services/playback_engine/playback_engine.dart';

import 'package:sonora/services/device_music_repository/device_music_repository.dart';

import 'package:sonora/services/source_resolver/local_file_source_resolver.dart';
import 'package:sonora/services/source_resolver/i_source_resolver.dart';

import 'package:sonora/services/track_loader/track_loader_service.dart';
import 'package:sonora/services/track_loader/track_repository.dart';

final storageBoxProvider = Provider<Box<dynamic>>((ref) {
  return Hive.box<dynamic>('storage');
});

final storageProvider = Provider<IKeyValueStorage>((ref) {
  final box = ref.watch(storageBoxProvider);

  return HiveKeyValueStorage(box);
});

final settingsProvider = AsyncNotifierProvider<SettingsProvider, Settings>(
  SettingsProvider.new,
);

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

final trackSourceResolverProvider = Provider<TrackSourceResolver>((ref) {
  return LocalFileSourceResolver();
});

final deviceMusicRepositoryProvider = Provider<DeviceMusicRepository>((ref) {
  return DeviceMusicRepository(
    resolver: ref.watch(trackSourceResolverProvider),
  );
});

final trackBoxProvider = Provider<Box<Track>>((ref) {
  return Hive.box<Track>('tracks');
});

final trackRepositoryProvider = Provider<TrackRepository>((ref) {
  return TrackRepository(ref.watch(trackBoxProvider));
});

final trackLoaderServiceProvider = Provider<TrackLoaderService>((ref) {
  return TrackLoaderService(
    ref.watch(deviceMusicRepositoryProvider),
    ref.watch(trackRepositoryProvider),
  );
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

final mainPlayerIdProvider = Provider<String>((ref) {
  return bootstrap.mainPlayerController.id;
});