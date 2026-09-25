import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:sonora/data/playlists/playlist_model.dart';

import 'package:sonora/services/playlist/platlist_repository.dart';

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
  void emit() => controller.add(box.values.toList());
  emit();
  box.listenable().addListener(emit);
  ref.onDispose(() {
    box.listenable().removeListener(emit);
    controller.close();
  });
  return controller.stream;
});