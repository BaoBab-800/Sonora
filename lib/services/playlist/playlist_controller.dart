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

  Future<Playlist> createPlaylist(String rawName, {String? initialTrackId}) async {
    final name = rawName.trim();

    if (name.isEmpty) throw PlaylistValidationException(PlaylistError.nameEmpty);
    if (name.length > 100) throw PlaylistValidationException(PlaylistError.nameTooLong);

    final maxOrder = _repo.getAll().fold<int>(-1, (max, p) => p.order > max ? p.order : max);
    final playlist = Playlist.create(name: name, order: maxOrder + 1);

    await _repo.save(playlist);

    if (initialTrackId != null) {
      await _repo.addTrack(playlist.id, initialTrackId);
    }

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

  Future<void> movePlaylist(String playlistId, {required bool up}) async {
    final playlists = _repo.getAll()..sort((a, b) => a.order.compareTo(b.order));
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    final targetIndex = up ? index - 1 : index + 1;
    if (targetIndex < 0 || targetIndex >= playlists.length) return;

    final current = playlists[index];
    final target = playlists[targetIndex];

    final tempOrder = current.order;
    current.order = target.order;
    target.order = tempOrder;

    await current.save();
    await target.save();
  }

  Future<void> deletePlaylist(String playlistId) async {
    await _repo.delete(playlistId);
    notifyListeners();
  }

  Future<void> addTrack(String playlistId, String trackId) => _repo.addTrack(playlistId, trackId);

  Future<void> removeTrack(String playlistId, String trackId) => _repo.removeTrack(playlistId, trackId);
}