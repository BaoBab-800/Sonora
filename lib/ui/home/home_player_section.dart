import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/core/l10n/l10n.dart';
import 'package:sonora/core/theme/theme.dart';
import 'package:sonora/core/providers/player_providers.dart';
import 'package:sonora/core/providers/track_providers.dart';

import 'package:sonora/data/player_controller/controller_state.dart';
import 'package:sonora/data/player_controller/repeat_mode.dart' as repeat;
import 'package:sonora/data/player_controller/track.dart';
import 'package:sonora/data/player_engine/player_status.dart';

import 'package:sonora/services/player_controller/i_player_controller.dart';

import '../playlists/add_to_playlist_sheet.dart';

class HomePlayerSection extends ConsumerStatefulWidget {
  const HomePlayerSection({super.key});

  @override
  ConsumerState<HomePlayerSection> createState() => _HomePlayerSectionState();
}

class _HomePlayerSectionState extends ConsumerState<HomePlayerSection> {
  StreamSubscription<ControllerState>? _playerSubscription;
  StreamSubscription<Map<String, ControllerState>>? _managerSubscription;
  ControllerState _state = const ControllerState();
  bool _isLoadingLibrary = false;
  bool _isFavorite = false;
  bool _isSeeking = false;
  double _seekPosition = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initialId = ref.read(selectedPlayerIdProvider);
    if (initialId != null) {
      _selectPlayer(initialId);
    }
  }

  IPlayerController? get _controller {
    final id = ref.watch(selectedPlayerIdProvider);
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
      _state = player.state;
    });
    _playerSubscription = player.stateStream.listen((state) {
      if (mounted) setState(() => _state = state);
    });
  }

  Future<void> _removeSelectedPlayer() async {
    final id = ref.watch(selectedPlayerIdProvider);
    if (id == null) return;
    await _playerSubscription?.cancel();
    _playerSubscription = null;
    await ref.read(playerManagerProvider).removePlayer(id);
    if (!mounted) return;
    setState(() {
      ref.read(selectedPlayerIdProvider.notifier).state = null;
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
      final tracks = await ref.read(trackLoaderServiceProvider).loadAndPersist();
      if (tracks.isEmpty) {
        if (mounted) setState(() => _error = context.l10n.noAudioTracksFoundOnTheDevice);
        return;
      }
      await _controller!.setQueue(tracks);
    } catch (error) {
      if (mounted) setState(() => _error = '${context.l10n.failedToLoadTheMediaLibrary}: $error');
    } finally {
      if (mounted) setState(() => _isLoadingLibrary = false);
    }
  }

  Future<void> _run(Future<void> Function(IPlayerController player) action) async {
    final player = _controller;
    if (player == null) {
      setState(() => _error = context.l10n.createAPlayerToStartPlayback);
      return;
    }
    try {
      await action(player);
    } catch (error) {
      if (mounted) setState(() => _error = '${context.l10n.playerError}: $error');
    }
  }

  Future<void> _showPlayersDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.players),

        content: SizedBox(
          width: 420,
          child: _PlayerList(
            playerIds: ref.read(playerManagerProvider).playerIds,
            selectedId: ref.watch(selectedPlayerIdProvider),
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
            child: Text(context.l10n.ok),
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
    ref.listen<String?>(selectedPlayerIdProvider, (previous, next) {
      if (next != null && next != previous) {
        _selectPlayer(next);
      }
    });

    final track = _state.currentTrack;
    final duration = _state.duration ?? track?.duration ?? Duration.zero;
    final maxPosition = duration.inMilliseconds.toDouble();
    final position = _state.position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble();
    final hasTrack = track != null;
    final sliderPosition = _isSeeking
        ? _seekPosition
        : position;

    final isPlaying = _state.status == PlayerStatus.playing;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.outline),
      ),

      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD84A4A),
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 8),
                Text(
                  context.l10n.nowPlaying,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: Color(0xFFA5A9B0),
                  ),
                ),

                const Spacer(),
                Text(
                  _state.queueLength == 0
                      ? context.l10n.noQueue
                      : '${_state.queueLength.toString().padLeft(2, '0')} ${context.l10n.tracks}',
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.1,
                    color: Color(0xFF616A78),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AlbumDisc(isPlaying: isPlaying),

                const SizedBox(width: 14),
                Expanded(child: _TrackDetails(track: track)),

                IconButton(
                  tooltip: context.l10n.selectAPlayer,
                  onPressed: _showPlayersDialog,
                  icon: const Icon(Icons.speaker_group_outlined),
                ),

                IconButton(
                  tooltip: context.l10n.removeCurrentPlayer,
                  onPressed: ref.watch(selectedPlayerIdProvider) == null ? null : _removeSelectedPlayer,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),

            const SizedBox(height: 20),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: context.colors.primary,
                inactiveTrackColor: context.colors.outline,
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              ),

              child: Slider(
                value: sliderPosition,
                max: maxPosition > 0 ? maxPosition : 1,

                onChangeStart: (value) {
                  setState(() {
                    _isSeeking = true;
                    _seekPosition = value;
                  });
                },

                onChanged: (value) {
                  setState(() {
                    _seekPosition = value;
                  });
                },

                onChangeEnd: (value) {
                  setState(() {
                    _isSeeking = false;
                  });

                  _run(
                        (p) => p.seek(
                      Duration(milliseconds: value.round()),
                    ),
                  );
                },
              ),
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
                    backgroundColor: const Color(0xffd84a4a),
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(19),
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

            const Divider(height: 36, color: Color(0xFF34363B)),

            Row(
              children: [
                IconButton.outlined(
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
                IconButton.outlined(
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
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                    ),

                    child: Slider(
                      value: _state.volume,
                      onChanged: hasTrack
                          ? (value) => _run((p) => p.setVolume(value))
                          : null,
                    ),
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
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              ),
              label: Text(_isLoadingLibrary
                  ? context.l10n.loadingMusic
                  : context.l10n.uploadMusicFromTheDevice,
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
                      child: Text(context.l10n.close),
                    ),
                  ],
                ),
              ),

            Row(
              children: [
                if (_state.queue.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => _showQueueDialog(_state.queue),
                    icon: const Icon(Icons.queue_music),
                    label: Text('${context.l10n.queue} · ${_state.queueLength}'),
                  ),
                ],

                const Spacer(),
                Builder(
                  builder: (context) {
                    final currentTrack = track;
                    return IconButton(
                      icon: const Icon(Icons.playlist_add),
                      onPressed: currentTrack == null
                          ? null
                          : () => showModalBottomSheet(
                        context: context,
                        builder: (_) => AddToPlaylistSheet(track: currentTrack),
                      ),
                    );
                  },
                ),

                IconButton(
                  tooltip: context.l10n.addToFavorites,
                  onPressed: hasTrack
                      ? () => setState(() => _isFavorite = !_isFavorite)
                      : null,
                  icon: Icon(
                    _isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: _isFavorite
                        ? const Color(0xffd84a4a)
                        : null,
                  ),
                ),
              ],
            ),
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
        title: Text(context.l10n.queue),
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

                subtitle: Text(track.artist ?? context.l10n.unknownArtist),

                trailing: IconButton(
                  icon: const Icon(Icons.playlist_add),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    builder: (_) => AddToPlaylistSheet(track: track),
                  ),
                ),

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
          track?.title ?? context.l10n.selectMusic,
          style: Theme.of(context).textTheme.titleLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),
        Text(
          track?.artist?.isNotEmpty == true
              ? track!.artist!
              : context.l10n.uploadMusicFromTheDevice,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _AlbumDisc extends StatelessWidget {
  const _AlbumDisc({required this.isPlaying});

  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark; final discColors = isDark
        ? const [
      Color(0xFF3D4045),
      Color(0xFF1C1D20),
      Color(0xFF101113),
    ] : const [
      Color(0xFF8B8D91),
      Color(0xFF5D5F64),
      Color(0xFF3A3C40),
    ];

    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,

        gradient: RadialGradient( colors: discColors, ),
        border: Border.all(color: const Color(0xFF4A4C52)),
      ),

      child: Center(
        child: Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: isPlaying
                ? const Color(0xFFD84A4A)
                : const Color(0xFF777A80),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xffb4b6ba), width: 2),
          ),
        ),
      ),
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
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(context.l10n.thePlayersHaveNotYetBeenCreated),
        ),

      ...playerIds.map((id) {
        final state = states[id];
        return ListTile(
          selected: id == selectedId,
          leading: const CircleAvatar(child: Icon(Icons.music_note)),
          title: Text(state?.currentTrack?.title ?? context.l10n.newPlayer),
          subtitle: Text('ID: ${id.substring(0, 8)}'),
          onTap: () => onSelect(id),
        );
      }),

      const SizedBox(height: 8),
      FilledButton.icon(
        onPressed: onCreate,
        icon: const Icon(Icons.add),
        label: Text(context.l10n.createPlayer),
      ),
    ]);
  }
}