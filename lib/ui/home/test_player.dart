import 'package:flutter/material.dart';

import 'package:sonora/services/player_manager/player_manager.dart';
import 'package:sonora/services/player_controller/i_player_controller.dart';
import 'package:sonora/services/player_controller/player_controller.dart';
import 'package:sonora/services/playback_engine/playback_engine.dart';
import 'package:sonora/services/device_music_repository/device_music_repository.dart';
import 'package:sonora/services/source_resolver/local_file_source_resolver.dart';

class PlayerTest extends StatefulWidget {
  const PlayerTest({super.key});

  @override
  State<PlayerTest> createState() => _PlayerTestState();
}

class _PlayerTestState extends State<PlayerTest> {
  late final PlayerManager _manager;
  IPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _manager = PlayerManager(
      controllerFactory: () => PlayerController(engine: PlaybackEngine()),
    );
  }

  Future<void> _playDeviceMusic() async {
    if (_controller != null) {
      await _controller!.play();
      return;
    }

    try {
      final repository = DeviceMusicRepository(resolver: LocalFileSourceResolver());
      final tracks = await repository.loadSongs();

      if (tracks.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('На устройстве не найдено треков')),
          );
        }
        return;
      }

      final controller = _manager.createPlayer();
      await controller.setQueue(tracks);
      await controller.play();

      setState(() {
        _controller = controller;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось запустить плеер: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _playDeviceMusic,
      child: const Card(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.play_arrow),
        ),
      ),
    );
  }
}