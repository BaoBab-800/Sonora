import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'playlist_model.g.dart';

@HiveType(typeId: 2)
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

  factory Playlist.create({required String name}) {
    return Playlist(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
    );
  }
}