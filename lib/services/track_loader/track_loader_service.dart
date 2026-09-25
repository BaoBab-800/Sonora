import 'package:sonora/data/player_controller/track.dart';

import '../device_music_repository/device_music_repository.dart';
import 'track_repository.dart';

class TrackLoaderService {
  final DeviceMusicRepository _songLoader;
  final TrackRepository _trackRepository;

  TrackLoaderService(this._songLoader, this._trackRepository);

  Future<List<Track>> loadAndPersist() async {
    final tracks = await _songLoader.loadSongs();
    await _trackRepository.saveAll(tracks);
    return tracks;
  }
}