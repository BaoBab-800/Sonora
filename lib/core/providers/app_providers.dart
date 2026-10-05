import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/app/app_bootstrap.dart';

import 'package:sonora/services/url/url_service.dart';

final mainPlayerIdProvider = Provider<String>((ref) {
  return mainPlayerController.id;
});

final urlService = Provider<UrlService>((ref) {
  return UrlService();
});