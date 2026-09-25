import 'package:hive/hive.dart';

part 'playlist_model.g.dart';

@HiveType(typeId: 0)
class Playlist extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> trackIds;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? updatedAt;

  Playlist({
    required this.id,
    required this.name,
    List<String>? trackIds,
    DateTime? createdAt,
    this.updatedAt,
  })  : trackIds = trackIds ?? [],
        createdAt = createdAt ?? DateTime.now();
}