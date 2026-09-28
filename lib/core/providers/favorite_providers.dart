import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:sonora/data/favorite/favorite_track.dart';
import 'package:sonora/data/player_controller/track.dart';

import 'package:sonora/services/favorite/favorites_repository.dart';

final favoritesBoxProvider = Provider<Box<FavoriteTrack>>((ref) {
  return Hive.box<FavoriteTrack>('favorites');
});

final tracksBoxProvider = Provider<Box<Track>>((ref) {
  return Hive.box<Track>('tracks');
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(
    favoritesBox: ref.watch(favoritesBoxProvider),
    tracksBox: ref.watch(tracksBoxProvider),
  );
});

final isFavoriteProvider = StreamProvider.family<bool, String>((ref, trackId) {
  final repository = ref.watch(favoritesRepositoryProvider);

  return repository.watchIsFavorite(trackId);
});