import 'package:hive/hive.dart';

part 'track.g.dart';

@HiveType(typeId: 1)
class Track extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String source;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String? artist;

  @HiveField(4)
  final int? durationMs;

  Duration? get duration => durationMs != null ? Duration(milliseconds: durationMs!) : null;

  Track({
    required this.id,
    required this.source,
    required this.title,
    this.artist,
    this.durationMs,
  });
}