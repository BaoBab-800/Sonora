import 'dart:io';

import 'i_source_resolver.dart';

final class LocalFileSourceResolver implements TrackSourceResolver {
  @override
  Future<String> resolve(String rawSource) async {
    final file = File(rawSource);
    if (!await file.exists()) {
      throw FileSystemException('Track file not found', rawSource);
    }
    return file.path;
  }
}