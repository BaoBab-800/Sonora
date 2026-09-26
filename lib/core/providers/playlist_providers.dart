import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:sonora/data/playlists/playlist_model.dart';
import 'package:sonora/data/player_controller/track.dart';

import 'package:sonora/services/playlist/platlist_repository.dart';
import 'package:sonora/services/playlist/playlist_controller.dart';

import 'storage_providers.dart';
import 'track_providers.dart';

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return PlaylistRepository(
    ref.watch(playlistBoxProvider),
    ref.watch(trackRepositoryProvider),
  );
});

final playlistsStreamProvider = StreamProvider<List<Playlist>>((ref) {
  final box = ref.watch(playlistBoxProvider);
  final controller = StreamController<List<Playlist>>();
  void emit() {
    final sorted = box.values.toList()..sort((a, b) => a.order.compareTo(b.order));
    controller.add(sorted);
  }

  emit();
  box.listenable().addListener(emit);
  ref.onDispose(() {
    box.listenable().removeListener(emit);
    controller.close();
  });

  return controller.stream;
});

final playlistByIdProvider = StreamProvider.family<Playlist?, String>((ref, playlistId) {
  final box = ref.watch(playlistBoxProvider);
  final controller = StreamController<Playlist?>();
  void emit() => controller.add(box.get(playlistId));

  emit();
  box.listenable().addListener(emit);
  ref.onDispose(() {
    box.listenable().removeListener(emit);
    controller.close();
  });
  return controller.stream;
});

final playlistTracksProvider = Provider.family<List<Track>, Playlist>((ref, playlist) {
  final trackRepo = ref.watch(trackRepositoryProvider);
  return playlist.trackIds.map(trackRepo.getById).whereType<Track>().toList();
});

final playlistControllerProvider = Provider<PlaylistController>((ref) {
  return PlaylistController(
    ref.watch(playlistRepositoryProvider),
  );
});