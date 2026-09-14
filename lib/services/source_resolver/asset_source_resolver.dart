import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import 'i_source_resolver.dart';

final class AssetSourceResolver implements TrackSourceResolver {
  final Map<String, String> _cache = {};

  @override
  Future<String> resolve(String rawSource) async {
    final cached = _cache[rawSource];
    if (cached != null && await File(cached).exists()) {
      return cached;
    }

    final byteData = await rootBundle.load(rawSource);
    final tempDir = await getTemporaryDirectory();
    final fileName = rawSource.split('/').last;
    final file = File('${tempDir.path}/$fileName');

    if (!await file.exists()) {
      await file.writeAsBytes(
        byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
    }

    _cache[rawSource] = file.path;
    return file.path;
  }
}