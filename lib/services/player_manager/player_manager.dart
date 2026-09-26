import 'dart:async';

import 'package:uuid/uuid.dart';

import 'package:sonora/data/player_controller/controller_state.dart';

import '../player_controller/i_player_controller.dart';

class PlayerNotFoundException implements Exception {
  final String id;
  const PlayerNotFoundException(this.id);

  @override
  String toString() => 'PlayerNotFoundException: player with id "$id" not found';
}

class PlayerManager {
  final IPlayerController Function(String id) _controllerFactory;
  final Uuid _uuid = const Uuid();

  final Map<String, IPlayerController> _players = {};
  final Map<String, StreamSubscription<ControllerState>> _subscriptions = {};
  final Map<String, ControllerState> _lastStates = {};

  final StreamController<Map<String, ControllerState>> _aggregatedController = StreamController<Map<String, ControllerState>>.broadcast();

  bool _isDisposed = false;

  PlayerManager({required IPlayerController Function(String id) controllerFactory}) : _controllerFactory = controllerFactory;

  Stream<Map<String, ControllerState>> get stateStream async* {
    yield Map.unmodifiable(_lastStates);
    yield* _aggregatedController.stream;
  }
  List<String> get playerIds => List.unmodifiable(_players.keys);

  IPlayerController createPlayer() {
    _throwIfDisposed();

    final id = _uuid.v4();
    final controller = _controllerFactory(id);

    _players[id] = controller;
    _subscriptions[id] = controller.stateStream.listen((state) {
      _lastStates[id] = state;
      _emitAggregated();
    });
    _lastStates[id] = controller.state;
    _emitAggregated();

    return controller;
  }

  IPlayerController? getPlayer(String id) => _players[id];

  Future<void> removePlayer(String id) async {
    _throwIfDisposed();

    final controller = _players[id];
    if (controller == null) {
      throw PlayerNotFoundException(id);
    }

    await _subscriptions[id]?.cancel();
    _subscriptions.remove(id);
    _players.remove(id);
    _lastStates.remove(id);

    await controller.dispose();
    _emitAggregated();
  }

  Future<void> disposeAll() async {
    _throwIfDisposed();
    final ids = List.of(_players.keys);
    for (final id in ids) {
      await removePlayer(id);
    }
  }

  Future<void> dispose() async {
    if (_isDisposed) return;

    await disposeAll();

    _isDisposed = true;
    await _aggregatedController.close();
  }

  void _emitAggregated() {
    if (_isDisposed || _aggregatedController.isClosed) return;
    _aggregatedController.add(Map.unmodifiable(_lastStates));
  }

  void _throwIfDisposed() {
    if (_isDisposed) {
      throw StateError('PlayerManager has already been disposed');
    }
  }
}