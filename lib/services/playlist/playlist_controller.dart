import 'package:flutter/cupertino.dart';

import 'package:sonora/data/playlists/playlist_model.dart';
import 'package:sonora/data/playlists/playlist_error.dart';

import 'platlist_repository.dart';

class PlaylistValidationException implements Exception {
  final PlaylistError message;
  PlaylistValidationException(this.message);
}

class PlaylistController extends ChangeNotifier {
  final PlaylistRepository _repo;
  PlaylistController(this._repo);

  Future<Playlist> createPlaylist(String rawName) async {
    final name = rawName.trim();

    if (name.isEmpty) throw PlaylistValidationException(PlaylistError.nameEmpty);
    if (name.length > 100) throw PlaylistValidationException(PlaylistError.nameTooLong);

    final playlist = Playlist.create(name: name);
    await _repo.save(playlist);
    notifyListeners();
    return playlist;
  }

  Future<void> renamePlaylist(String playlistId, String rawName) async {
    final name = rawName.trim();

    if (name.isEmpty) {
      throw PlaylistValidationException(PlaylistError.nameEmpty);
    }
    if (name.length > 100) {
      throw PlaylistValidationException(PlaylistError.nameTooLong);
    }

    final playlist = _repo.getById(playlistId);
    if (playlist == null) return;

    playlist.name = name;
    playlist.updatedAt = DateTime.now();
    await playlist.save();
  }

  Future<void> deletePlaylist(String playlistId) async {
    await _repo.delete(playlistId);
    notifyListeners();
  }
}