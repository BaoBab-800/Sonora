import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:sonora/data/player_controller/track.dart';
import 'package:sonora/data/favorite/favorite_track.dart';
import 'package:sonora/data/favorite/favorites_playlist.dart';

class FavoritesRepository {
  FavoritesRepository({
    required Box<FavoriteTrack> favoritesBox,
    required Box<Track> tracksBox,
  })  : _favorites = favoritesBox,
        _tracks = tracksBox;

  final Box<FavoriteTrack> _favorites;
  final Box<Track> _tracks;
  ValueListenable<Box<FavoriteTrack>> get listenable => _favorites.listenable();

  bool isFavorite(String trackId) => _favorites.containsKey(trackId);

  Future<bool> toggle(String trackId) async {
    if (_favorites.containsKey(trackId)) {
      await _favorites.delete(trackId);
      return false;
    }

    await _favorites.put(
      trackId,
      FavoriteTrack(trackId: trackId, likedAt: DateTime.now()),
    );

    return true;
  }

  FavoritesPlaylist get playlist {
    final entries = _favorites.values
        .where((f) => _tracks.containsKey(f.trackId))
        .toList()
      ..sort((a, b) => b.likedAt.compareTo(a.likedAt));

    return FavoritesPlaylist(
      trackIds: [for (final e in entries) e.trackId],
    );
  }

  Future<void> removeOrphans() async {
    final orphans = _favorites.keys.where((id) => !_tracks.containsKey(id)).toList();
    if (orphans.isEmpty) return;
    await _favorites.deleteAll(orphans);
  }

  Stream<bool> watchIsFavorite(String trackId) async* {
    yield isFavorite(trackId);

    await for (final _ in _favorites.watch(key: trackId)) {
      yield isFavorite(trackId);
    }
  }
}