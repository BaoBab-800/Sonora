import 'dart:async';
import 'dart:developer' as developer;

import 'package:media_kit/media_kit.dart';

import 'package:sonora/data/player_engine/warped.dart';
import 'package:sonora/data/player_engine/player_status.dart';
import 'package:sonora/data/player_engine/player_state.dart' as sonora;

import 'i_playback_engine.dart';

final class PlaybackEngine implements IPlaybackEngine {
  final Player _player = Player();
  final StreamController<sonora.PlayerState> _stateController = StreamController<sonora.PlayerState>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  sonora.PlayerState _state = const sonora.PlayerState();
  bool _isDisposed = false;

  void _updateState({
    PlayerStatus? status,
    Duration? position,
    Wrapped<Duration?>? duration,
  }) {
    if (_isDisposed || _stateController.isClosed) return;

    _state = sonora.PlayerState(
      status: status ?? _state.status,
      position: position ?? _state.position,
      duration: duration != null ? duration.value : _state.duration,
    );

    _stateController.add(_state);
  }

  PlaybackEngine() {
    _subscriptions.addAll([
      _player.stream.playing.listen((playing) {
        if (_state.status == PlayerStatus.completed) return;
        _updateState(
          status: playing ? PlayerStatus.playing : PlayerStatus.paused,
        );
      }),

      _player.stream.buffering.listen((buffering) {
        if (buffering) {
          _updateState(status: PlayerStatus.loading);
        }
      }),

      _player.stream.position.listen((position) {
        _updateState(position: position);
      }),

      _player.stream.duration.listen((duration) {
        _updateState(duration: Wrapped(duration));
      }),

      _player.stream.completed.listen((completed) {
        if (completed) {
          _updateState(status: PlayerStatus.completed);
        }
      }),

      _player.stream.error.listen((error) {
        developer.log('Player error: $error', name: 'PlaybackEngine');
        _updateState(status: PlayerStatus.error);
      }),
    ]);
  }

  @override
  Stream<sonora.PlayerState> get stateStream => _stateController.stream;

  @override
  Future<void> open(String source) async {
    developer.log('Opening source: $source', name: 'PlaybackEngine');
    _updateState(
      status: PlayerStatus.loading,
      position: Duration.zero,
      duration: const Wrapped(null),
    );

    try {
      await _player.open(Media(source), play: false);
    } catch (e, st) {
      developer.log('Failed to open source: $e', name: 'PlaybackEngine', error: e, stackTrace: st);
      _updateState(status: PlayerStatus.error);
      rethrow;
    }
  }

  @override
  Future<void> play() => _guard(_player.play, 'Player started');

  @override
  Future<void> pause() => _guard(_player.pause, 'Player paused');

  @override
  Future<void> stop() => _guard(_player.stop, 'Player stopped');

  @override
  Future<void> seek(Duration position) {
    final clamped = _clampPosition(position);
    return _guard(
          () => _player.seek(clamped),
      'Seeked to: $clamped',
    );
  }

  @override
  Future<void> setVolume(double volume) {
    final clamped = volume.clamp(0.0, 1.0) * 100;
    return _guard(
          () => _player.setVolume(clamped),
      'Volume set: $clamped',
    );
  }

  Duration _clampPosition(Duration position) {
    final max = _state.duration;
    if (position < Duration.zero) return Duration.zero;
    if (max != null && position > max) return max;
    return position;
  }

  Future<void> _guard(Future<void> Function() action, String logMessage) async {
    try {
      await action();
      developer.log(logMessage, name: 'PlaybackEngine');
    } catch (e, st) {
      developer.log('Action failed: $e', name: 'PlaybackEngine', error: e, stackTrace: st);
      _updateState(status: PlayerStatus.error);
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    for (final sub in _subscriptions) {
      await sub.cancel();
    }

    await _stateController.close();
    await _player.dispose();
    developer.log('Player resources have been released.', name: 'PlaybackEngine');
  }
}