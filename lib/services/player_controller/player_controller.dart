import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import 'package:sonora/data/player_engine/player_status.dart';
import 'package:sonora/data/player_engine/player_state.dart' as sonora;

import 'package:sonora/data/player_controller/track.dart';
import 'package:sonora/data/player_controller/repeat_mode.dart';
import 'package:sonora/data/player_controller/playback_queue.dart';
import 'package:sonora/data/player_controller/controller_state.dart';

import '../playback_engine/i_playback_engine.dart';
import 'i_player_controller.dart';

class PlayerController implements IPlayerController {
  final IPlaybackEngine _engine;

  final StreamController<ControllerState> _stateController = StreamController<ControllerState>.broadcast();
  late final StreamSubscription<sonora.PlayerState> _engineSub;

  PlaybackQueue _queue = const PlaybackQueue();
  sonora.PlayerState _engineState = const sonora.PlayerState();
  ControllerState _state = const ControllerState();
  double _volume = 1.0;
  bool _isDisposed = false;

  PlayerController({required IPlaybackEngine engine}) : _engine = engine {
    _engineSub = _engine.stateStream.listen(_onEngineState);
  }

  @override
  Stream<ControllerState> get stateStream => _stateController.stream;

  @override
  ControllerState get state => _state;

  void _onEngineState(sonora.PlayerState engineState) {
    _engineState = engineState;
    if (engineState.status == PlayerStatus.completed) {
      unawaited(_handleTrackCompleted());
      return;
    }
    _emit();
  }

  Future<void> _handleTrackCompleted() async {
    if (_queue.repeatMode == RepeatMode.one) {
      await _openCurrent(autoPlay: true);
      _emit();
      return;
    }

    final nextIndex = _resolveIndexAfterEnd(
      fromIndex: _queue.currentIndex,
      length: _queue.tracks.length,
      repeatMode: _queue.repeatMode,
    );

    if (nextIndex == null) {
      _emit();
      return;
    }

    _queue = _queue.copyWith(currentIndex: nextIndex);
    await _openCurrent(autoPlay: true);
    _emit();
  }

  int? _resolveIndexAfterEnd({
    required int fromIndex,
    required int length,
    required RepeatMode repeatMode,
  }) {
    if (length == 0) return null;
    final next = fromIndex + 1;
    if (next < length) return next;
    return repeatMode == RepeatMode.all ? 0 : null;
  }

  int? _resolveIndexBeforeStart({
    required int fromIndex,
    required int length,
    required RepeatMode repeatMode,
  }) {
    if (length == 0) return null;
    final prev = fromIndex - 1;
    if (prev >= 0) return prev;
    return repeatMode == RepeatMode.all ? length - 1 : null;
  }

  Future<String> resolveAssetToFilePath(String assetKey) async {
    final byteData = await rootBundle.load(assetKey);
    final tempDir = await getTemporaryDirectory();
    final fileName = assetKey.split('/').last;
    final file = File('${tempDir.path}/$fileName');

    if (!await file.exists()) {
      await file.writeAsBytes(
        byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
    }

    return file.path;
  }

  @override
  Future<void> play() => _engine.play();

  @override
  Future<void> pause() => _engine.pause();

  @override
  Future<void> seek(Duration position) => _engine.seek(position);

  @override
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _engine.setVolume(_volume);
    _emit();
  }

  Future<void> _openCurrent({required bool autoPlay}) async {
    final track = _queue.currentTrack;
    if (track == null) return;

    await _engine.open(track.source);
    await _engine.setVolume(_volume);

    if (autoPlay) {
      await _engine.play();
    }
  }

  // Queue management
  @override
  Future<void> setQueue(List<Track> tracks, {int startIndex = 0}) async {
    final originalOrder = tracks.map((t) => t.id).toList();
    final clampedIndex = tracks.isEmpty ? -1 : startIndex.clamp(0, tracks.length -1);

    _queue = PlaybackQueue(
      tracks: List.of(tracks),
      originalOrder: originalOrder,
      currentIndex: clampedIndex,
      repeatMode: _queue.repeatMode,
      shuffleEnabled: false,
    );

    if (_queue.currentTrack != null) {
      await _openCurrent(autoPlay: false);
    }
    _emit();
  }

  @override
  Future<void> addToQueue(Track track) async {
    final wasEmpty = _queue.isEmpty;

    _queue = _queue.copyWith(
      tracks: [..._queue.tracks, track],
      originalOrder: [..._queue.originalOrder, track.id],
      currentIndex: wasEmpty ? 0 : _queue.currentIndex,
    );

    if (wasEmpty) {
      await _openCurrent(autoPlay: false);
    }
    _emit();
  }

  @override
  Future<void> removeFromQueue(String trackId) async {
    final removedIndex = _queue.tracks.indexWhere((t) => t.id == trackId);
    if (removedIndex == -1) return;

    final removingCurrent = removedIndex == _queue.currentIndex;

    final newTracks = List<Track>.of(_queue.tracks)..removeAt(removedIndex);
    final newOriginalOrder = List<String>.of(_queue.originalOrder)..remove(trackId);

    if (!removingCurrent) {
      final adjustedIndex = removedIndex < _queue.currentIndex
          ? _queue.currentIndex -1
          : _queue.currentIndex;
      _queue = _queue.copyWith(
        tracks: newTracks,
        originalOrder: newOriginalOrder,
        currentIndex: newTracks.isEmpty ? -1 : adjustedIndex,
      );
      _emit();
      return;
    }

    if (newTracks.isEmpty) {
      _queue = _queue.copyWith(
        tracks: newTracks,
        originalOrder: newOriginalOrder,
        currentIndex: -1,
      );
      await _engine.stop();
      _emit();
      return;
    }

    final landingIndex = removedIndex < newTracks.length
        ? removedIndex
        : (_queue.repeatMode == RepeatMode.all ? 0 : null);

    if (landingIndex == null) {
      _queue = _queue.copyWith(
        tracks: newTracks,
        originalOrder: newOriginalOrder,
        currentIndex: newTracks.length - 1,
      );
      await _engine.stop();
      _emit();
      return;
    }

    _queue = _queue.copyWith(
      tracks: newTracks,
      originalOrder: newOriginalOrder,
      currentIndex: landingIndex,
    );
    await _openCurrent(autoPlay: true);
    _emit();
  }

  @override
  Future<void> next() async {
    final index = _resolveIndexAfterEnd(
      fromIndex: _queue.currentIndex,
      length: _queue.tracks.length,
      repeatMode: _queue.repeatMode,
    );
    if (index == null) return;
    _queue = _queue.copyWith(currentIndex: index);
    await _openCurrent(autoPlay: true);
    _emit();
  }

  @override
  Future<void> previous() async {
    final index = _resolveIndexBeforeStart(
      fromIndex: _queue.currentIndex,
      length: _queue.tracks.length,
      repeatMode: _queue.repeatMode,
    );
    if (index == null) return;
    _queue = _queue.copyWith(currentIndex: index);
    await _openCurrent(autoPlay: true);
    _emit();
  }

  @override
  Future<void> skipTo(int index) async {
    if (index < 0 || index >= _queue.tracks.length) return;
    _queue = _queue.copyWith(currentIndex: index);
    await _openCurrent(autoPlay: true);
    _emit();
  }

  @override
  void setRepeatMode(RepeatMode mode) {
    _queue = _queue.copyWith(repeatMode: mode);
    _emit();
  }

  @override
  void setShuffle(bool enabled) {
    if (enabled == _queue.shuffleEnabled) return;

    final currentId = _queue.currentTrack?.id;

    final List<Track> newTracks;
    if (enabled) {
      newTracks = List.of(_queue.tracks)..shuffle();
    } else {
      final byId = {for (final t in _queue.tracks) t.id: t};
      newTracks = _queue.originalOrder
          .where(byId.containsKey)
          .map((id) => byId[id]!)
          .toList();
    }

    final newIndex =
    currentId == null ? -1 : newTracks.indexWhere((t) => t.id == currentId);

    _queue = _queue.copyWith(
      tracks: newTracks,
      shuffleEnabled: enabled,
      currentIndex: newIndex,
    );
    _emit();
  }

  // Lifecycle
  void _emit() {
    if (_isDisposed || _stateController.isClosed) return;
    _state = ControllerState(
      status: _engineState.status,
      position: _engineState.position,
      duration: _engineState.duration,
      currentTrack: _queue.currentTrack,
      currentIndex: _queue.currentIndex,
      queueLength: _queue.tracks.length,
      repeatMode: _queue.repeatMode,
      shuffleEnabled: _queue.shuffleEnabled,
      volume: _volume,
    );
    _stateController.add(_state);
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    await _engineSub.cancel();
    await _stateController.close();
    await _engine.dispose();
  }
}