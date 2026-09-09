import 'dart:developer' as developer;
import 'dart:async';

import 'package:media_kit/media_kit.dart';

import 'package:sonora/data/player/player_status.dart';
import 'package:sonora/data/player/player_state.dart' as sonora;

import 'i_playback_engine.dart';

final class PlaybackEngine implements IPlaybackEngine {
  final Player _player = Player();

  final StreamController<sonora.PlayerState> _stateController =
  StreamController<sonora.PlayerState>.broadcast();

  sonora.PlayerState _state = const sonora.PlayerState();

  void _updateState({
    PlayerStatus? status,
    Duration? position,
    Duration? duration,
  }) {
    _state = sonora.PlayerState(
      status: status ?? _state.status,
      position: position ?? _state.position,
      duration: duration ?? _state.duration,
    );

    _stateController.add(_state);
  }

  PlaybackEngine() {
    _player.stream.playing.listen((playing) {
      _updateState(
        status: playing
            ? PlayerStatus.playing
            : PlayerStatus.paused,
      );
    });

    _player.stream.position.listen((position) {
      _updateState(
        position: position,
      );
    });

    _player.stream.duration.listen((duration) {
      _updateState(
        duration: duration,
      );
    });

    _player.stream.completed.listen((completed) {
      if (completed) {
        _updateState(
          status: PlayerStatus.completed,
        );
      }
    });
  }

  @override
  Stream<sonora.PlayerState> get stateStream {
    return _stateController.stream;
  }

  @override
  Future<void> open(String source) {
    developer.log('The player is open. Asset: $source', name: 'PlaybackEngine');
    return _player.open(
      Media(source)
    );
  }

  @override
  Future<void> play() {
    developer.log('The player has started.', name: 'PlaybackEngine');
    return _player.play();
  }

  @override
  Future<void> pause() {
    developer.log('The player is paused.', name: 'PlaybackEngine');
    return _player.pause();
  }

  @override
  Future<void> stop() {
    developer.log('Player stopped.', name: 'PlaybackEngine');
    return _player.stop();
  }

  @override
  Future<void> seek(Duration position) {
    developer.log(
      'The player\'s current position has been moved to: $position',
      name: 'PlaybackEngine',
    );
    return _player.seek(position);
  }

  @override
  Future<void> setVolume(double volume) {
    developer.log('Volume set: $volume', name: 'PlaybackEngine');
    return _player.setVolume(volume);
  }

  @override
  Future<void> dispose() {
    developer.log(
      'Player resources have been released.',
      name: 'PlaybackEngine',
    );
    return _player.dispose();
  }
}