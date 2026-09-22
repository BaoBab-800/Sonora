import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:audio_service/audio_service.dart';

import 'app/sonora_app.dart';
import 'app/app_bootstrap.dart' as bootstrap;

import 'core/providers/providers.dart';

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

  await Hive.initFlutter();
  await Hive.openBox<dynamic>('storage');

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SonoraApp(),
    ),
  );
}