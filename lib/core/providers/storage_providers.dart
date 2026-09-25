import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:sonora/data/player_controller/track.dart';
import 'package:sonora/data/playlists/playlist_model.dart';

import 'package:sonora/services/storage/i_key_value_storage.dart';
import 'package:sonora/services/storage/hive_key_value_storage.dart';

final storageBoxProvider = Provider<Box<dynamic>>((ref) {
  return Hive.box<dynamic>('storage');
});

final storageProvider = Provider<IKeyValueStorage>((ref) {
  final box = ref.watch(storageBoxProvider);

  return HiveKeyValueStorage(box);
});

final trackBoxProvider = Provider<Box<Track>>((ref) {
  return Hive.box<Track>('tracks');
});

final playlistBoxProvider = Provider<Box<Playlist>>((ref) {
  return Hive.box<Playlist>('playlists');
});