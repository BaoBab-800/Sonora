import '../player_controller/track.dart';

class Artist {
  final String key;
  final String name;
  final List<String> trackIds;

  const Artist({
    required this.key,
    required this.name,
    required this.trackIds,
  });

  bool get isUnknown => key == _unknownKey;
}

const _unknownKey = '';

String normalizeArtist(String? raw) {
  final value = (raw ?? '').trim();
  if (value.isEmpty || value == '<unknown>') return _unknownKey;
  return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

List<Artist> groupByArtist(List<Track> tracks) {
  final groups = <String, List<Track>>{};
  for (final t in tracks) {
    groups.putIfAbsent(normalizeArtist(t.artist), () => []).add(t);
  }

  final artists = groups.entries.map((e) {
    final counts = <String, int>{};
    for (final t in e.value) {
      final n = (t.artist ?? '').trim();
      counts[n] = (counts[n] ?? 0) + 1;
    }
    final name = e.key == _unknownKey
        ? 'Unknown artist'
        : counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    return Artist(
      key: e.key,
      name: name,
      trackIds: e.value.map((t) => t.id).toList(),
    );
  }).toList();

  artists.sort((a, b) {
    if (a.isUnknown != b.isUnknown) return a.isUnknown ? 1 : -1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  return artists;
}