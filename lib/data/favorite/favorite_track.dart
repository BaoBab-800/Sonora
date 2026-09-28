import 'package:hive/hive.dart';

part 'favorite_track.g.dart';

@HiveType(typeId: 3)
class FavoriteTrack {
  @HiveField(0)
  final String trackId;
  @HiveField(1)
  final DateTime likedAt;

  const FavoriteTrack({required this.trackId, required this.likedAt});
}