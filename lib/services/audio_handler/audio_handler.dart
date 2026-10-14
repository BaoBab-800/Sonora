import 'dart:async';
import 'package:audio_service/audio_service.dart';

import 'package:sonora/data/player_controller/controller_state.dart';
import 'package:sonora/data/player_engine/player_status.dart';

import 'package:sonora/services/player_controller/i_player_controller.dart';

class SonoraAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  IPlayerController? _controller;
  StreamSubscription<ControllerState>? _sub;

  SonoraAudioHandler();

  Future<void> attachController(IPlayerController? controller) async {
    if (identical(_controller, controller)) return;
    await _sub?.cancel();
    _controller = controller;
    if (controller == null) {
      mediaItem.add(null);
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
        updatePosition: Duration.zero,
      ));
      return;
    }
    _sub = controller.stateStream.listen(_onControllerState);
    _onControllerState(controller.state);
  }

  void _onControllerState(ControllerState state) {
    final track = state.currentTrack;

    if (track == null) {
      mediaItem.add(null);
    } else {
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
  Future<void> play() async {
    await _controller?.play();
  }

  @override
  Future<void> pause() async {
    await _controller?.pause();
  }

  @override
  Future<void> stop() async {
    await _controller?.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _controller?.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    await _controller?.next();
  }

  @override
  Future<void> skipToPrevious() async {
    await _controller?.previous();
  }

  Future<void> dispose() async {
    await _sub?.cancel();
  }
}