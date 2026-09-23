import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/core/providers/providers.dart';
import 'package:sonora/core/theme/theme.dart';
import 'package:sonora/data/player_controller/controller_state.dart';
import 'package:sonora/data/player_controller/repeat_mode.dart' as repeat;
import 'package:sonora/data/player_controller/track.dart';
import 'package:sonora/data/player_engine/player_status.dart';
import 'package:sonora/services/player_controller/i_player_controller.dart';

class HomePlayerSection extends ConsumerStatefulWidget {
  const HomePlayerSection({super.key});

  @override
  ConsumerState<HomePlayerSection> createState() => _HomePlayerSectionState();
}

class _HomePlayerSectionState extends ConsumerState<HomePlayerSection> {
  StreamSubscription<ControllerState>? _playerSubscription;
  StreamSubscription<Map<String, ControllerState>>? _managerSubscription;
  String? _selectedPlayerId;
  ControllerState _state = const ControllerState();
  bool _isLoadingLibrary = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _managerSubscription = ref.read(playerManagerProvider).stateStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  IPlayerController? get _controller {
    final id = _selectedPlayerId;
    return id == null ? null : ref.read(playerManagerProvider).getPlayer(id);
  }

  Future<void> _createPlayer({bool loadLibrary = false}) async {
    final player = ref.read(playerManagerProvider).createPlayer();
    await _selectPlayer(player.id);
    if (loadLibrary) await _loadDeviceMusic();
  }

  Future<void> _selectPlayer(String id) async {
    await _playerSubscription?.cancel();
    final player = ref.read(playerManagerProvider).getPlayer(id);
    if (player == null || !mounted) return;
    setState(() {
      _selectedPlayerId = id;
      _state = player.state;
    });
    _playerSubscription = player.stateStream.listen((state) {
      if (mounted) setState(() => _state = state);
    });
  }

  Future<void> _removeSelectedPlayer() async {
    final id = _selectedPlayerId;
    if (id == null) return;
    await _playerSubscription?.cancel();
    _playerSubscription = null;
    await ref.read(playerManagerProvider).removePlayer(id);
    if (!mounted) return;
    setState(() {
      _selectedPlayerId = null;
      _state = const ControllerState();
    });
    final remaining = ref.read(playerManagerProvider).playerIds;
    if (remaining.isNotEmpty) await _selectPlayer(remaining.first);
  }

  Future<void> _loadDeviceMusic() async {
    if (_isLoadingLibrary) return;
    if (_controller == null) await _createPlayer();
    setState(() {
      _isLoadingLibrary = true;
      _error = null;
    });
    try {
      final tracks = await ref.read(deviceMusicRepositoryProvider).loadSongs();
      if (tracks.isEmpty) {
        if (mounted) setState(() => _error = 'На устройстве не найдено аудиотреков.');
        return;
      }
      await _controller!.setQueue(tracks);
    } catch (error) {
      if (mounted) setState(() => _error = 'Не удалось загрузить медиатеку: $error');
    } finally {
      if (mounted) setState(() => _isLoadingLibrary = false);
    }
  }

  Future<void> _run(Future<void> Function(IPlayerController player) action) async {
    final player = _controller;
    if (player == null) {
      setState(() => _error = 'Создайте плеер, чтобы начать воспроизведение.');
      return;
    }
    try {
      await action(player);
    } catch (error) {
      if (mounted) setState(() => _error = 'Ошибка плеера: $error');
    }
  }

  Future<void> _showPlayersDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Плееры'),

        content: SizedBox(
          width: 420,
          child: _PlayerList(
            playerIds: ref.read(playerManagerProvider).playerIds,
            selectedId: _selectedPlayerId,
            states: _playerStates(),

            onSelect: (id) async {
              Navigator.pop(context);
              await _selectPlayer(id);
            },

            onCreate: () async {
              Navigator.pop(context);
              await _createPlayer();
            },
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Готово'),
          )
        ],
      ),
    );
  }

  Map<String, ControllerState> _playerStates() {
    final manager = ref.read(playerManagerProvider);
    return {
      for (final id in manager.playerIds)
        if (manager.getPlayer(id) case final player?) id: player.state,
    };
  }

  @override
  void dispose() {
    _playerSubscription?.cancel();
    _managerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final track = _state.currentTrack;
    final duration = _state.duration ?? track?.duration ?? Duration.zero;
    final maxPosition = duration.inMilliseconds.toDouble();
    final position = _state.position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble();
    final hasTrack = track != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Плеер',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _TrackDetails(track: track)),

              IconButton(
                tooltip: 'Выбрать плеер',
                onPressed: _showPlayersDialog,
                icon: const Icon(Icons.speaker_group_outlined),
              ),

              IconButton(
                tooltip: 'Удалить текущий плеер',
                onPressed: _selectedPlayerId == null ? null : _removeSelectedPlayer,
                icon: const Icon(Icons.delete_outline),
              ),
            ]),

            const SizedBox(height: 20),
            Slider(
              value: position,
              max: maxPosition > 0
                  ? maxPosition
                  : 1, onChanged: hasTrack
                ? (value) => _run((p) => p.seek(Duration(milliseconds: value.round())))
                : null,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TimeLabel(value: Duration(milliseconds: position.round())),
                _TimeLabel(value: duration),
              ],
            ),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: hasTrack
                      ? () => _run((p) => p.previous())
                      : null,
                  iconSize: 30,
                  icon: const Icon(Icons.skip_previous),
                ),

                IconButton(
                  onPressed: hasTrack
                      ? () => _run((p) => p.seek(_state.position - const Duration(seconds: 10)))
                      : null,
                  icon: const Icon(Icons.replay_10),
                ),

                const SizedBox(width: 8),
                FilledButton(
                  onPressed: hasTrack
                      ? () => _run((p) => _state.status == PlayerStatus.playing
                      ? p.pause()
                      : p.play())
                      : null,
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(18),
                  ),
                  child: Icon(
                    _state.status == PlayerStatus.playing
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: 32,
                  ),
                ),

                const SizedBox(width: 8),
                IconButton(
                  onPressed: hasTrack
                      ? () => _run((p) => p.seek(_state.position + const Duration(seconds: 10)))
                      : null,
                  icon: const Icon(Icons.forward_10),
                ),

                IconButton(
                  onPressed: hasTrack
                      ? () => _run((p) => p.next())
                      : null,
                  iconSize: 30,
                  icon: const Icon(Icons.skip_next),
                ),
              ],
            ),

            const Divider(height: 32),

            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: hasTrack
                      ? () => _controller?.setShuffle(!_state.shuffleEnabled)
                      : null,
                  icon: Icon(
                    _state.shuffleEnabled
                        ? Icons.shuffle_on
                        : Icons.shuffle,
                  ),
                ),

                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: hasTrack
                      ? _cycleRepeat
                      : null,
                  icon: Icon(
                    _state.repeatMode == repeat.RepeatMode.one
                        ? Icons.repeat_one
                        : Icons.repeat,
                  ),
                ),

                const SizedBox(width: 16),
                const Icon(Icons.volume_up_outlined),

                Expanded(
                  child: Slider(
                    value: _state.volume,
                    onChanged: hasTrack
                        ? (value) => _run((p) => p.setVolume(value))
                        : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isLoadingLibrary
                  ? null
                  : _loadDeviceMusic,
              icon: _isLoadingLibrary
                  ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.library_music_outlined),
              label: Text(_isLoadingLibrary
                  ? 'Загрузка музыки…'
                  : 'Загрузить музыку с устройства',
              ),
            ),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: MaterialBanner(
                  content: Text(_error!),
                  leading: const Icon(Icons.error_outline),
                  actions: [
                    TextButton(
                      onPressed: () => setState(() => _error = null),
                      child: const Text('Закрыть'),
                    ),
                  ],
                ),
              ),

            if (_state.queue.isNotEmpty) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => _showQueueDialog(_state.queue),
                icon: const Icon(Icons.queue_music),
                label: Text('Очередь · ${_state.queueLength}'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _cycleRepeat() {
    const modes = repeat.RepeatMode.values;
    _controller?.setRepeatMode(modes[(_state.repeatMode.index + 1) % modes.length]);
  }

  Future<void> _showQueueDialog(List<Track> tracks) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очередь'),
        content: SizedBox(
          width: 480,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: tracks.length,

            itemBuilder: (_, index) {
              final track = tracks[index];
              return ListTile(
                selected: index == _state.currentIndex,

                leading: Text('${index + 1}'),

                title: Text(
                  track.title, maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                subtitle: Text(track.artist ?? 'Неизвестный исполнитель'),

                onTap: () {
                  Navigator.pop(context);
                  _run((player) => player.skipTo(index));
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TrackDetails extends StatelessWidget {
  const _TrackDetails({this.track});
  final Track? track;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          track?.title ?? 'Выберите музыку',
          style: Theme.of(context).textTheme.titleLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),
        Text(
          track?.artist?.isNotEmpty == true
              ? track!.artist!
              : 'Загрузите треки с устройства',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _TimeLabel extends StatelessWidget {
  const _TimeLabel({required this.value});
  final Duration value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${value.inMinutes.remainder(60).toString().padLeft(2, '0')}:${value.inSeconds.remainder(60).toString().padLeft(2, '0')}',
    );
  }
}

class _PlayerList extends StatelessWidget {
  const _PlayerList({
    required this.playerIds,
    required this.selectedId,
    required this.states,
    required this.onSelect,
    required this.onCreate,
  });

  final List<String> playerIds;
  final String? selectedId;
  final Map<String, ControllerState> states;
  final ValueChanged<String> onSelect;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (playerIds.isEmpty)
        const Padding(padding: EdgeInsets.all(12),
          child: Text('Плееры ещё не созданы.'),
        ),

      ...playerIds.map((id) {
        final state = states[id];
        return ListTile(
          selected: id == selectedId,
          leading: const CircleAvatar(child: Icon(Icons.music_note)),
          title: Text(state?.currentTrack?.title ?? 'Новый плеер'),
          subtitle: Text('ID: ${id.substring(0, 8)}'),
          onTap: () => onSelect(id),
        );
      }),

      const SizedBox(height: 8),
      FilledButton.icon(
        onPressed: onCreate,
        icon: const Icon(Icons.add),
        label: const Text('Создать плеер'),
      ),
    ]);
  }
}