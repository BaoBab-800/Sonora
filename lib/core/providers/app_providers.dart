import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/app/app_bootstrap.dart';

final mainPlayerIdProvider = Provider<String>((ref) {
  return mainPlayerController.id;
});