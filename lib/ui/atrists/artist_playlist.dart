import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/core/providers/artists_provider.dart';

import 'package:sonora/data/player_controller/track.dart';

class ArtistPlaylist extends ConsumerWidget {
  final String artistKey;
  const ArtistPlaylist({super.key, required this.artistKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artist = ref.watch(artistProvider(artistKey));
    final tracks = ref.watch(artistTracksProvider(artistKey));

    return Scaffold(
      appBar: AppBar(title: Text(artist?.name ?? '')),
      body: _TrackListView(tracks: tracks),
    );
  }
}

class _TrackListView extends StatelessWidget {
  final List<Track> tracks;
  const _TrackListView({required this.tracks});

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}