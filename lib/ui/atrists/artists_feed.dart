import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/core/l10n/l10n.dart';
import 'package:sonora/core/providers/artists_provider.dart';

import 'artist_playlist.dart';

class ArtistsFeed extends ConsumerWidget {
  const ArtistsFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artists = ref.watch(artistsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.artists,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      body: artists.isEmpty
          ? Center(child: Text(context.l10n.noArtistsUploadSongs))
          : ListView.builder(
        itemCount: artists.length,
        itemBuilder: (context, i) {
          final artist = artists[i];
          return ListTile(
            leading: CircleAvatar(
              child: Text(artist.isUnknown ? '?' : artist.name[0].toUpperCase()),
            ),

            title: Text(artist.name),

            subtitle: Text(
              _tracksLabel(context, artist.trackIds.length),
            ),

            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ArtistPlaylist(artistKey: artist.key)),
            ),
          );
        },
      ),
    );
  }

  String _tracksLabel(BuildContext context, int n) {
    final mod10 = n % 10, mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return '$n ${context.l10n.track.toLowerCase()}';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return '$n ${context.l10n.tracks.toLowerCase()}';
    return '$n ${context.l10n.tracksL.toLowerCase()}';
  }
}