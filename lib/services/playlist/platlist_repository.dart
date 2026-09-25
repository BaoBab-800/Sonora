import 'package:hive/hive.dart';

import 'package:sonora/data/player_controller/track.dart';
import 'package:sonora/data/playlists/playlist_model.dart';

import '../track_loader/track_repository.dart';

class PlaylistRepository {
  final Box<Playlist> _box;
  final TrackRepository _trackRepository;

  PlaylistRepository(this._box, this._trackRepository);

  Future<void> save(Playlist playlist) async {
    await _box.put(playlist.id, playlist);
  }

  Playlist? getById(String id) => _box.get(id);

  List<Playlist> getAll() => _box.values.toList();

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> addTrack(String playlistId, String trackId) async {
    final playlist = _box.get(playlistId);
    if (playlist == null) return;
    if (!playlist.trackIds.contains(trackId)) {
      playlist.trackIds.add(trackId);
      playlist.updatedAt = DateTime.now();
      await playlist.save();
    }
  }

  Future<void> removeTrack(String playlistId, String trackId) async {
    final playlist = _box.get(playlistId);
    if (playlist == null) return;
    playlist.trackIds.remove(trackId);
    playlist.updatedAt = DateTime.now();
    await playlist.save();
  }

  List<Track> resolveTracks(Playlist playlist) {
    return playlist.trackIds
        .map(_trackRepository.getById)
        .whereType<Track>()
        .toList();
  }
}