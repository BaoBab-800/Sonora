import 'package:flutter/cupertino.dart' as cupertino;

import 'track.dart';
import 'repeat_mode.dart';
import '../player_engine/warped.dart';

@cupertino.immutable
class PlaybackQueue {
  final List<Track> tracks;
  final int currentIndex;
  final RepeatMode repeatMode;
  final bool shuffleEnabled;
  final List<int>? shuffleOrder;

  const PlaybackQueue({
    this.tracks = const [],
    this.currentIndex = -1,
    this.repeatMode = RepeatMode.none,
    this.shuffleEnabled = false,
    this.shuffleOrder,
  });

  Track? get currentTrack => (currentIndex >= 0 && currentIndex < tracks.length) ? tracks[currentIndex] : null;

  bool get isEmpty => tracks.isEmpty;

  PlaybackQueue copyWith({
    List<Track>? tracks,
    int? currentIndex,
    RepeatMode? repeatMode,
    bool? shuffleEnabled,
    Wrapped<List<int>?>? shuffleOrder,
  }) {
    return PlaybackQueue(
      tracks: tracks ?? this.tracks,
      currentIndex: currentIndex ?? this.currentIndex,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      shuffleOrder: shuffleOrder != null ? shuffleOrder.value : this.shuffleOrder,
    );
  }
}