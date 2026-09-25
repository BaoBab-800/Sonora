import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:audio_service/audio_service.dart';

import 'app/sonora_app.dart';
import 'app/app_bootstrap.dart' as bootstrap;

import 'core/providers/player_providers.dart';

import 'data/playlists/playlist_model.dart' as playlist;
import 'data/player_controller/track.dart' as track;

import 'services/audio_handler/audio_handler.dart';
import 'services/player_controller/i_player_controller.dart';

late final ProviderContainer container;
late final IPlayerController mainPlayerController;
late final AudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final container = ProviderContainer();
  final manager = container.read(playerManagerProvider);

  bootstrap.mainPlayerController = manager.createPlayer();

  bootstrap.audioHandler = await AudioService.init(
    builder: () => SonoraAudioHandler(bootstrap.mainPlayerController),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.sonora.channel.audio',
      androidNotificationChannelName: 'Sonora playback',
    ),
  );

  await Hive.initFlutter('Sonora');

  Hive.registerAdapter(track.TrackAdapter());
  Hive.registerAdapter(playlist.PlaylistAdapter());

  await Hive.openBox<dynamic>('storage');
  await Hive.openBox<track.Track>('tracks');
  await Hive.openBox<playlist.Playlist>('playlists');

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SonoraApp(),
    ),
  );
}