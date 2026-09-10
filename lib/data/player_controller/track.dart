import 'package:flutter/cupertino.dart';

@immutable
class Track {
  final String id;
  final String source;
  final String title;
  final String? artist;
  final Duration? duration;

  const Track({
    required this.id,
    required this.source,
    required this.title,
    this.artist,
    this.duration,
  });
}