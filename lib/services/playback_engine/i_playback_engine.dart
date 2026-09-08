import 'package:sonora/data/player/player_state.dart';

abstract interface class IPlaybackEngine {
  Stream<PlayerState> get stateStream;

  Future<void> open(String source);
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> setVolume(double volume);
  Future<void> dispose();
}