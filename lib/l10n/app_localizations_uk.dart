// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get denchik => 'Денчик';

  @override
  String get menu => 'Меню';

  @override
  String get settings => 'Налаштування';

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Система';

  @override
  String get themeLight => 'Світла';

  @override
  String get themeDark => 'Темна';

  @override
  String get language => 'Мова';

  @override
  String get noAudioTracksFoundOnTheDevice => 'No audio tracks found on the device.';

  @override
  String get failedToLoadTheMediaLibrary => 'Failed to load the media library';

  @override
  String get createAPlayerToStartPlayback => 'Create a player to start playback.';

  @override
  String get playerError => 'Помилка плеєрa';

  @override
  String get localLibary => 'ЛОКАЛЬНА БІБЛІОТЕКА';

  @override
  String get nowPlaying => 'ЗАРАЗ ГРАЄ';

  @override
  String get tracks => 'ПІСЕНЬ';

  @override
  String get noQueue => 'НЕМАЄ ЧЕРГИ';

  @override
  String get selectAPlayer => 'Вибрати плеєр';

  @override
  String get removeCurrentPlayer => 'Видалити поточний плеєр';

  @override
  String get players => 'Плеєри';

  @override
  String get ok => 'Ок';

  @override
  String get loadingMusic => 'Завантаження музики...';

  @override
  String get uploadMusicFromTheDevice => 'Завантажити музику з пристрою';

  @override
  String get close => 'Закрити';

  @override
  String get queue => 'Черга';

  @override
  String get addToFavorites => 'Додати до вибраного';

  @override
  String get unknownArtist => 'Невідомий виконавець';

  @override
  String get selectMusic => 'Вибрати музику';

  @override
  String get thePlayersHaveNotYetBeenCreated => 'Плеєрів ще не створено.';

  @override
  String get newPlayer => 'Новий плеєр';

  @override
  String get createPlayer => 'Створити плеєр';

  @override
  String get playlists => 'Плейлисти';

  @override
  String get allYourPlaylists => 'Усі ваші плейлисти';

  @override
  String get artists => 'Виконавці';

  @override
  String get allYourArtists => 'Усі ваші виконавці';

  @override
  String get favorite => 'Вибране';

  @override
  String get yourFavoriteSongs => 'Ваші улюблені пісні';

  @override
  String get collection => 'Колекція';

  @override
  String get comingSoon => 'Скоро з\'явитися';

  @override
  String get noPlaylistsYet => 'Поки що немає плейлистів.';

  @override
  String get playlistNameEmpty => 'Назва плейлиста порожня.';

  @override
  String get playlistNameTooLong => 'Назва плейлиста занадто довга.';

  @override
  String get newPlaylist => 'Новий плейлист';

  @override
  String get nameThePlaylist => 'Назвіть плейлист';

  @override
  String get create => 'Створити';

  @override
  String get editName => 'Редагувати назву';

  @override
  String get moveUp => 'Перемістити вгору';

  @override
  String get moveDown => 'Перемістити вниз';

  @override
  String get delete => 'Видалити';

  @override
  String get deletePlaylistTitle => 'Видалення плейлиста';

  @override
  String deletePlaylistConfirm(String playlist) {
    return 'Ви впевнені, що хочете видалити плейлист $playlist?';
  }

  @override
  String get newPlaylistName => 'Нова назва плейлиста';

  @override
  String get save => 'Зберегти';
}
