import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/services/source_resolver/local_file_source_resolver.dart';
import 'package:sonora/services/source_resolver/i_source_resolver.dart';

import 'package:sonora/services/device_music_repository/device_music_repository.dart';

import 'package:sonora/services/track_loader/track_repository.dart';
import 'package:sonora/services/track_loader/track_loader_service.dart';

import 'storage_providers.dart';

final trackSourceResolverProvider = Provider<TrackSourceResolver>((ref) {
  return LocalFileSourceResolver();
});

final deviceMusicRepositoryProvider = Provider<DeviceMusicRepository>((ref) {
  return DeviceMusicRepository(
    resolver: ref.watch(trackSourceResolverProvider),
  );
});

final trackRepositoryProvider = Provider<TrackRepository>((ref) {
  return TrackRepository(ref.watch(trackBoxProvider));
});

final trackLoaderServiceProvider = Provider<TrackLoaderService>((ref) {
  return TrackLoaderService(
    ref.watch(deviceMusicRepositoryProvider),
    ref.watch(trackRepositoryProvider),
  );
});