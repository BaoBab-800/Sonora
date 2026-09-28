class FavoritesPlaylist {
  const FavoritesPlaylist({required this.trackIds});

  final List<String> trackIds;

  int get length => trackIds.length;
}