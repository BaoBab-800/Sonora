import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonora/l10n/app_localizations.dart';

import 'package:sonora/core/l10n/l10n.dart';
import 'package:sonora/core/theme/theme.dart';
import 'package:sonora/core/providers/playlist_providers.dart';

import 'package:sonora/data/playlists/playlist_error.dart';
import 'package:sonora/data/playlists/playlist_model.dart';

import 'package:sonora/services/playlist/playlist_controller.dart';

class EditPlaylistNameDialog extends ConsumerStatefulWidget {
  final Playlist playlist;
  const EditPlaylistNameDialog({super.key, required this.playlist});

  @override
  ConsumerState<EditPlaylistNameDialog> createState() => _EditPlaylistNameDialogState();
}

class _EditPlaylistNameDialogState extends ConsumerState<EditPlaylistNameDialog> {
  late final _controller = TextEditingController(text: widget.playlist.name);
  PlaylistError? _error;
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await ref
          .read(playlistControllerProvider)
          .renamePlaylist(widget.playlist.id, _controller.text);
      if (mounted) Navigator.of(context).pop();
    } on PlaylistValidationException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.editName),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: context.l10n.newPlaylistName,
          hintStyle: TextStyle(color: context.colors.outline),
          errorText: _error == null ? null : _mapError(_error!, context.l10n),
        ),
        onSubmitted: (_) => _isSaving ? null : _submit(),
      ),

      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(context.l10n.close),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ) : Text(context.l10n.save),
        ),
      ],
    );
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