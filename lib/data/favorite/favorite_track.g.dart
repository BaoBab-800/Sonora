// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_track.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteTrackAdapter extends TypeAdapter<FavoriteTrack> {
  @override
  final int typeId = 3;

  @override
  FavoriteTrack read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteTrack(
      trackId: fields[0] as String,
      likedAt: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteTrack obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.trackId)
      ..writeByte(1)
      ..write(obj.likedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteTrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
