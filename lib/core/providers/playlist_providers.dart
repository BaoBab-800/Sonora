import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:sonora/data/playlists/playlist_model.dart';

import 'package:sonora/services/playlist/platlist_repository.dart';
import 'package:sonora/services/playlist/playlist_controller.dart';

import 'storage_providers.dart';
import 'track_providers.dart';

typedef PlaylistSnapshot = ({String id, String name, List<String> trackIds});

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

final playlistByIdProvider = StreamProvider.family<PlaylistSnapshot?, String>((ref, playlistId) {
  final box = ref.watch(playlistBoxProvider);
  final listenable = box.listenable();
  final controller = StreamController<PlaylistSnapshot?>();

  void emit() {
    final p = box.get(playlistId);
    controller.add(
      p == null ? null : (id: p.id, name: p.name, trackIds: List.of(p.trackIds)),
    );
  }

  emit();
  listenable.addListener(emit);
  ref.onDispose(() {
    listenable.removeListener(emit);
    controller.close();
  });
  return controller.stream;
});

final playlistControllerProvider = Provider<PlaylistController>((ref) {
  return PlaylistController(
    ref.watch(playlistRepositoryProvider),
  );
});