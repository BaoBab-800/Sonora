import 'package:flutter/cupertino.dart' as cupertino;

import 'track.dart';
import 'repeat_mode.dart';
import '../player_engine/player_status.dart';

@cupertino.immutable
class ControllerState {
  final PlayerStatus status;
  final Duration position;
  final Duration? duration;
  final Track? currentTrack;
  final int currentIndex;
  final int queueLength;
  final List<Track> queue;
  final RepeatMode repeatMode;
  final bool shuffleEnabled;
  final double volume;

  const ControllerState({
    this.status = PlayerStatus.idle,
    this.position = Duration.zero,
    this.duration,
    this.currentTrack,
    this.currentIndex = -1,
    this.queueLength = 0,
    this.queue = const [],
    this.repeatMode = RepeatMode.none,
    this.shuffleEnabled = false,
    this.volume = 1.0,
  });
}