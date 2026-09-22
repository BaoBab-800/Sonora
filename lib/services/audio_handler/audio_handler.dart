import 'dart:async';
import 'package:audio_service/audio_service.dart';

import 'package:sonora/data/player_controller/controller_state.dart';
import 'package:sonora/data/player_engine/player_status.dart';

import 'package:sonora/services/player_controller/i_player_controller.dart';

class SonoraAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final IPlayerController _controller;
  late final StreamSubscription<ControllerState> _sub;

  SonoraAudioHandler(this._controller) {
    _sub = _controller.stateStream.listen(_onControllerState);
    _onControllerState(_controller.state);
  }

  void _onControllerState(ControllerState state) {
    final track = state.currentTrack;

    if (track != null) {
      mediaItem.add(MediaItem(
        id: track.id,
        title: track.title,
        artist: track.artist,
        duration: state.duration,
      ));
    }

    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        state.status == PlayerStatus.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: _mapProcessingState(state.status),
      playing: state.status == PlayerStatus.playing,
      updatePosition: state.position,
      bufferedPosition: state.position,
      speed: 1.0,
    ));
  }

  AudioProcessingState _mapProcessingState(PlayerStatus status) {
    switch (status) {
      case PlayerStatus.idle:
        return AudioProcessingState.idle;
      case PlayerStatus.loading:
        return AudioProcessingState.loading;
      case PlayerStatus.playing:
      case PlayerStatus.paused:
        return AudioProcessingState.ready;
      case PlayerStatus.completed:
        return AudioProcessingState.completed;
      case PlayerStatus.error:
        return AudioProcessingState.error;
    }
  }

  @override
  Future<void> play() => _controller.play();

  @override
  Future<void> pause() => _controller.pause();

  @override
  Future<void> stop() async {
    await _controller.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _controller.seek(position);

  @override
  Future<void> skipToNext() => _controller.next();

  @override
  Future<void> skipToPrevious() => _controller.previous();

  Future<void> dispose() => _sub.cancel();
}