import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonora/data/settings/settings_model.dart';

import 'package:sonora/services/storage/i_key_value_storage.dart';
import 'package:sonora/services/storage/hive_key_value_storage.dart';

import 'package:sonora/services/settings/settings_service.dart';

final storageBoxProvider = Provider<Box<dynamic>>((ref) {
  return Hive.box<dynamic>('storage');
});

final storageProvider = Provider<IKeyValueStorage>((ref) {
  final box = ref.watch(storageBoxProvider);

  return HiveKeyValueStorage(box);
});

final settingsService = AsyncNotifierProvider<SettingsService, Settings>(
  SettingsService.new,
);