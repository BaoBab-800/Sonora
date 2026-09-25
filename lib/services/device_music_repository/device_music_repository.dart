import 'package:on_audio_query/on_audio_query.dart';

import 'package:sonora/data/player_controller/track.dart';

import 'package:sonora/services/source_resolver/i_source_resolver.dart';

import 'i_device_music_repository.dart';

final class DeviceMusicRepository implements IDeviceMusicRepository {
  final OnAudioQuery _audioQuery;
  final TrackSourceResolver _resolver;

  DeviceMusicRepository({
    OnAudioQuery? audioQuery,
    required TrackSourceResolver resolver,
  }) : _audioQuery = audioQuery ?? OnAudioQuery(),
        _resolver = resolver;

  @override
  Future<List<Track>> loadSongs() async {
    final hasPermission = await _audioQuery.checkAndRequest(retryRequest: true);
    if (!hasPermission) {
      throw StateError('Access to the media library has not been granted.');
    }

    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    final tracks = <Track>[];
    for (final song in songs) {
      tracks.add(await _songToTrack(song));
    }
    return tracks;
  }

  Future<Track> _songToTrack(SongModel song) async {
    final resolvedSource = await _resolver.resolve(song.data);
    return Track(
      id: song.id.toString(),
      source: resolvedSource,
      title: song.title,
      artist: song.artist,
      durationMs: song.duration,
    );
  }
}