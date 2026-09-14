abstract interface class TrackSourceResolver {
  Future<String> resolve(String rawSource);
}