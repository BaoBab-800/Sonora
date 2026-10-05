import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:sonora/app/app_bootstrap.dart';

import 'package:sonora/services/url/url_service.dart';

final mainPlayerIdProvider = Provider<String>((ref) {
  return mainPlayerController.id;
});

final urlService = Provider<UrlService>((ref) {
  return UrlService();
});

final packageInfoProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});