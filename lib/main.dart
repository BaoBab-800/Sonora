import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:audio_service/audio_service.dart';

import 'app/sonora_app.dart';
import 'app/app_bootstrap.dart' as bootstrap;

import 'data/playlists/playlist_model.dart' as playlist;
import 'data/player_controller/track.dart' as track;
import 'data/favorite/favorite_track.dart';

import 'services/audio_handler/audio_handler.dart';

late final ProviderContainer container;
late final AudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final container = ProviderContainer();
  bootstrap.audioHandler = await AudioService.init(
    builder: () => SonoraAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.sonora.channel.audio',
      androidNotificationChannelName: 'Sonora playback',
      androidNotificationOngoing: true,
    ),
  );

  await Hive.initFlutter('Sonora');

  Hive.registerAdapter(track.TrackAdapter());
  Hive.registerAdapter(playlist.PlaylistAdapter());
  Hive.registerAdapter(FavoriteTrackAdapter());

  await Hive.openBox<dynamic>('storage');
  await Hive.openBox<track.Track>('tracks');
  await Hive.openBox<playlist.Playlist>('playlists');
  await Hive.openBox<FavoriteTrack>('favorites');

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SonoraApp(),
    ),
  );
}
