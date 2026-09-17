import 'package:sonora/data/player_controller/controller_state.dart';
import 'package:sonora/data/player_controller/track.dart';
import 'package:sonora/data/player_controller/repeat_mode.dart';

abstract interface class IPlayerController {
  String get id;

  Stream<ControllerState> get stateStream;
  ControllerState get state;

  // Делегируется в PlaybackEngine
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> setVolume(double volume);

  // Управление очередью
  Future<void> setQueue(List<Track> tracks, {int startIndex = 0});
  Future<void> addToQueue(Track track);
  Future<void> removeFromQueue(String trackId);
  Future<void> next();
  Future<void> previous();
  Future<void> skipTo(int index);
  void setRepeatMode(RepeatMode mode);
  void setShuffle(bool enabled);

  Future<void> dispose();
}