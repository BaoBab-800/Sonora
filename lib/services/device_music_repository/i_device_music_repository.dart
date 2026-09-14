import 'package:sonora/data/player_controller/track.dart';

abstract interface class IDeviceMusicRepository {
  Future<List<Track>> loadSongs();
}