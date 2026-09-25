import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/data/settings/settings_model.dart';

import 'package:sonora/services/settings/settings_provider.dart';

final settingsProvider = AsyncNotifierProvider<SettingsProvider, Settings>(
  SettingsProvider.new,
);
