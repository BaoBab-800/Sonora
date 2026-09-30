import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/data/artists/artist.dart';
import 'package:sonora/data/player_controller/track.dart';

import 'track_providers.dart';

final artistsProvider = Provider<List<Artist>>((ref) {
  final tracks = ref.watch(trackRepositoryProvider).getAll();
  return groupByArtist(tracks);
});

final artistProvider = Provider.family<Artist?, String>((ref, key) {
  final artists = ref.watch(artistsProvider);
  for (final a in artists) {
    if (a.key == key) return a;
  }
  return null;
});

final artistTracksProvider = Provider.family<List<Track>, String>((ref, key) {
  final artist = ref.watch(artistProvider(key));
  if (artist == null) return const [];
  final tracks = ref.watch(trackRepositoryProvider).getAll();
  final ids = artist.trackIds.toSet();
  return tracks.where((t) => ids.contains(t.id)).toList();
});