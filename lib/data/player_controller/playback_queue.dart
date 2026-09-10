import 'package:flutter/cupertino.dart' as cupertino;

import 'track.dart';
import 'repeat_mode.dart';

@cupertino.immutable
class PlaybackQueue {
  final List<Track> tracks;
  final List<String> originalOrder;
  final int currentIndex;
  final RepeatMode repeatMode;
  final bool shuffleEnabled;

  const PlaybackQueue({
    this.tracks = const [],
    this.originalOrder = const [],
    this.currentIndex = -1,
    this.repeatMode = RepeatMode.none,
    this.shuffleEnabled = false,
  });

  Track? get currentTrack => (currentIndex >= 0 && currentIndex < tracks.length) ? tracks[currentIndex] : null;

  bool get isEmpty => tracks.isEmpty;

  PlaybackQueue copyWith({
    List<Track>? tracks,
    List<String>? originalOrder,
    int? currentIndex,
    RepeatMode? repeatMode,
    bool? shuffleEnabled,
  }) {
    return PlaybackQueue(
      tracks: tracks ?? this.tracks,
      originalOrder: originalOrder ?? this.originalOrder,
      currentIndex: currentIndex ?? this.currentIndex,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
    );
  }
}