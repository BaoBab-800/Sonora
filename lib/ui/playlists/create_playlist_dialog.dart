import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonora/core/l10n/l10n.dart';

import 'package:sonora/core/providers/playlist_providers.dart';
import 'package:sonora/data/playlists/playlist_error.dart';
import 'package:sonora/l10n/app_localizations.dart';

import 'package:sonora/services/playlist/playlist_controller.dart';

class CreatePlaylistDialog extends ConsumerStatefulWidget {
  const CreatePlaylistDialog({super.key});

  @override
  ConsumerState<CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends ConsumerState<CreatePlaylistDialog> {
  final _controller = TextEditingController();
  String? _errorText;
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sumbit() async {
    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    try {
      await ref.read(playlistControllerProvider).createPlaylist(_controller.text);
      if (mounted) Navigator.of(context).pop();
    } on PlaylistValidationException catch (e) {
      setState(() => _errorText = _mapError(e.message, context.l10n));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _mapError(PlaylistError error, AppLocalizations l10n) {
    switch (error) {
      case PlaylistError.nameEmpty:
        return l10n.playlistNameEmpty;
      case PlaylistError.nameTooLong:
        return l10n.playlistNameTooLong;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.newPlaylist),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: context.l10n.nameThePlaylist,
          errorText: _errorText,
        ),
        onSubmitted: (_) => _isSaving ? null : _sumbit(),
      ),

      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(context.l10n.close),
        ),
        
        FilledButton(
          onPressed: _isSaving ? null : _sumbit,
          child: _isSaving
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ) : Text(context.l10n.create),
        ),
      ],
    );
  }
}