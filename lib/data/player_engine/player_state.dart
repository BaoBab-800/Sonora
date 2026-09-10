import 'player_status.dart';

class PlayerState {
  final PlayerStatus status;
  final Duration position;
  final Duration? duration;

  const PlayerState({
    this.status = PlayerStatus.idle,
    this.position = Duration.zero,
    this.duration,
  });
}