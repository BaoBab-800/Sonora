import 'package:hive/hive.dart';

import 'package:sonora/data/player_controller/track.dart';

class TrackRepository {
  final Box<Track> _box;
  TrackRepository(this._box);

  Future<void> saveAll(List<Track> tracks) async {
    final map = {for (final t in tracks) t.id: t};
    await _box.putAll(map);
  }

  Track? getById(String id) => _box.get(id);

  List<Track> getAll() => _box.values.toList();
}