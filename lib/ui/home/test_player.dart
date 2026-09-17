import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sonora/data/player_controller/controller_state.dart';
import 'package:sonora/data/player_controller/repeat_mode.dart' as repeat;
import 'package:sonora/data/player_controller/track.dart';
import 'package:sonora/data/player_engine/player_status.dart';

import 'package:sonora/services/device_music_repository/device_music_repository.dart';
import 'package:sonora/services/playback_engine/playback_engine.dart';
import 'package:sonora/services/player_controller/i_player_controller.dart';
import 'package:sonora/services/player_controller/player_controller.dart';
import 'package:sonora/services/player_manager/player_manager.dart';
import 'package:sonora/services/source_resolver/local_file_source_resolver.dart';

/// A manual test bench for the Manager → Controller → Engine playback chain.
///
/// On Android, songs are read from the device media library after the user
/// grants the system audio permission.
class PlayerTest extends StatefulWidget {
  const PlayerTest({super.key});

  @override
  State<PlayerTest> createState() => _PlayerTestState();
}

class _PlayerTestState extends State<PlayerTest> {
  late final PlayerManager _manager;
  IPlayerController? _controller;
  StreamSubscription<ControllerState>? _stateSubscription;

  ControllerState _state = const ControllerState();
  List<Track> _tracks = const [];
  bool _isLoadingLibrary = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _manager = PlayerManager(
      controllerFactory: (id) => PlayerController(id: id, engine: PlaybackEngine()),
    );
  }

  Future<void> _loadDeviceMusic() async {
    if (_isLoadingLibrary) return;
    setState(() {
      _isLoadingLibrary = true;
      _error = null;
    });

    try {
      final tracks = await DeviceMusicRepository(
        resolver: LocalFileSourceResolver(),
      ).loadSongs();

      if (tracks.isEmpty) {
        setState(() => _error = 'На устройстве не найдено аудиотреков.');
        return;
      }

      final controller = _controller ?? _manager.createPlayer();
      if (_controller == null) {
        _controller = controller;
        _stateSubscription = controller.stateStream.listen((state) {
          if (mounted) setState(() => _state = state);
        });
      }

      await controller.setQueue(tracks);
      if (!mounted) return;
      setState(() => _tracks = tracks);
    } catch (error) {
      if (mounted) setState(() => _error = 'Не удалось загрузить медиатеку: $error');
    } finally {
      if (mounted) setState(() => _isLoadingLibrary = false);
    }
  }

  void _togglePlayback() {
    if (_state.status == PlayerStatus.playing) {
      _run((controller) => controller.pause());
    } else {
      _run((controller) => controller.play());
    }
  }

  void _seekBy(Duration delta) {
    _run((controller) => controller.seek(_state.position + delta));
  }

  void _cycleRepeat() {
    const modes = repeat.RepeatMode.values;
    final next = modes[(_state.repeatMode.index + 1) % modes.length];
    _controller?.setRepeatMode(next);
  }

  Future<void> _run(Future<void> Function(IPlayerController controller) action) async {
    final controller = _controller;
    if (controller == null) {
      setState(() => _error = 'Сначала загрузите песни с устройства.');
      return;
    }
    try {
      await action(controller);
    } catch (error) {
      if (mounted) setState(() => _error = 'Ошибка плеера: $error');
    }
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    unawaited(_manager.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final track = _state.currentTrack;
    final duration = _state.duration ?? track?.duration ?? Duration.zero;
    final maxPosition = duration.inMilliseconds.toDouble();
    final position = _state.position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('M–C–E test bench'),
        actions: [
          IconButton(
            tooltip: 'Загрузить музыку с устройства',
            onPressed: _isLoadingLibrary ? null : _loadDeviceMusic,
            icon: const Icon(Icons.library_music_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Header(
              songCount: _tracks.length,
              playerCount: _manager.playerIds.length,
              loading: _isLoadingLibrary,
              onLoad: _loadDeviceMusic,
            ),
            const SizedBox(height: 16),
            _NowPlayingCard(
              track: track,
              state: _state,
              position: position,
              maxPosition: maxPosition,
              onPositionChanged: (value) => _run(
                    (controller) => controller.seek(Duration(milliseconds: value.round())),
              ),
              onPlayPause: _togglePlayback,
              onStop: () => _run((controller) => controller.stop()),
              onPrevious: () => _run((controller) => controller.previous()),
              onNext: () => _run((controller) => controller.next()),
              onRewind: () => _seekBy(const Duration(seconds: -10)),
              onForward: () => _seekBy(const Duration(seconds: 10)),
              onShuffle: () => _controller?.setShuffle(!_state.shuffleEnabled),
              onRepeat: _cycleRepeat,
              onVolumeChanged: (value) => _run((controller) => controller.setVolume(value)),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              MaterialBanner(
                content: Text(_error!),
                leading: const Icon(Icons.error_outline),
                actions: [TextButton(onPressed: () => setState(() => _error = null), child: const Text('Закрыть'))],
              ),
            ],
            const SizedBox(height: 20),
            Text('Очередь устройства', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (_state.queue.isEmpty)
              const _EmptyQueue()
            else
              ..._state.queue.asMap().entries.map((entry) => _TrackTile(
                track: entry.value,
                index: entry.key,
                selected: entry.key == _state.currentIndex,
                onTap: () => _run((controller) => controller.skipTo(entry.key)),
              )),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.songCount, required this.playerCount, required this.loading, required this.onLoad});
  final int songCount;
  final int playerCount;
  final bool loading;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Проверка Manager → Controller → Engine', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Плееров в Manager: $playerCount • Треков в очереди: $songCount'),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: loading ? null : onLoad, icon: loading ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.folder_open), label: Text(loading ? 'Загрузка…' : 'Загрузить музыку Android')),
      ]),
    ),
  );
}

class _NowPlayingCard extends StatelessWidget {
  const _NowPlayingCard({required this.track, required this.state, required this.position, required this.maxPosition, required this.onPositionChanged, required this.onPlayPause, required this.onStop, required this.onPrevious, required this.onNext, required this.onRewind, required this.onForward, required this.onShuffle, required this.onRepeat, required this.onVolumeChanged});
  final Track? track;
  final ControllerState state;
  final double position;
  final double maxPosition;
  final ValueChanged<double> onPositionChanged;
  final VoidCallback onPlayPause, onStop, onPrevious, onNext, onRewind, onForward, onShuffle, onRepeat;
  final ValueChanged<double> onVolumeChanged;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(track?.title ?? 'Трек не выбран', style: Theme.of(context).textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(track?.artist?.isNotEmpty == true ? track!.artist! : 'Неизвестный исполнитель'),
        const SizedBox(height:12),
        Text('Engine status: ${state.status.name} • ${state.currentIndex + 1}/${state.queueLength}'),
        Slider(value: position, max: maxPosition > 0 ? maxPosition : 1, onChanged: track == null ? null : onPositionChanged),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_format(Duration(milliseconds: position.round()))), Text(_format(Duration(milliseconds: maxPosition.round())))]),
        Wrap(alignment: WrapAlignment.center, spacing: 4, children: [
          IconButton(tooltip: 'Предыдущий', onPressed: track == null ? null : onPrevious, icon: const Icon(Icons.skip_previous)),
          IconButton(tooltip: 'Назад 10 секунд', onPressed: track == null ? null : onRewind, icon: const Icon(Icons.replay_10)),
          FilledButton.tonalIcon(onPressed: track == null ? null : onPlayPause, icon: Icon(state.status == PlayerStatus.playing ? Icons.pause : Icons.play_arrow), label: Text(state.status == PlayerStatus.playing ? 'Пауза' : 'Старт')),
          IconButton(tooltip: 'Остановить', onPressed: track == null ? null : onStop, icon: const Icon(Icons.stop)),
          IconButton(tooltip: 'Вперёд 10 секунд', onPressed: track == null ? null : onForward, icon: const Icon(Icons.forward_10)),
          IconButton(tooltip: 'Следующий', onPressed: track == null ? null : onNext, icon: const Icon(Icons.skip_next)),
        ]),
        const Divider(),
        Row(children: [
          IconButton.filledTonal(tooltip: 'Перемешать очередь', onPressed: track == null ? null : onShuffle, icon: Icon(state.shuffleEnabled ? Icons.shuffle_on : Icons.shuffle)),
          const SizedBox(width: 8),
          IconButton.filledTonal(tooltip: 'Повтор: ${state.repeatMode.name}', onPressed: track == null ? null : onRepeat, icon: Icon(state.repeatMode == repeat.RepeatMode.one ? Icons.repeat_one : Icons.repeat)),
          const SizedBox(width: 16), const Icon(Icons.volume_up_outlined),
          Expanded(child: Slider(value: state.volume, onChanged: track == null ? null : onVolumeChanged)),
        ]),
      ]),
    ),
  );
}

class _TrackTile extends StatelessWidget {
  const _TrackTile({required this.track, required this.index, required this.selected, required this.onTap});
  final Track track;
  final int index;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    color: selected ? Theme.of(context).colorScheme.secondaryContainer : null,
    child: ListTile(onTap: onTap, leading: CircleAvatar(child: Text('${index + 1}')), title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis), subtitle: Text(track.artist?.isNotEmpty == true ? track.artist! : 'Неизвестный исполнитель', maxLines: 1, overflow: TextOverflow.ellipsis), trailing: Text(_format(track.duration ?? Duration.zero))),
  );
}

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue();
  @override
  Widget build(BuildContext context) => const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('Нажмите «Загрузить музыку Android», предоставьте доступ к аудио и выберите трек из появившегося списка.')));
}

String _format(Duration value) {
  final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '${value.inHours > 0 ? '${value.inHours}:' : ''}$minutes:$seconds';
}