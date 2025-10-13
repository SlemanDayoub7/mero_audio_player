import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/features/music_library/domain/entities/audio_file/audio_file.dart';
import 'package:mero_audio_player/features/playlist/presentation/bloc/playlist_bloc.dart';
import 'package:mero_audio_player/features/settings/presentation/pages/change_background/change_background_page.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';

Future<void> showCreatePlaylistDialog(
  BuildContext context,
  Set<AudioFile> selectedAudios,
) async {
  final nameController = TextEditingController();
  final playlistBloc = context.read<PlaylistBloc>();
  return await showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          backgroundColor: globalBackgroundColor,
          title: Text(
            LocaleKeys.playlistName.tr(),
            style: TextStyles.titleLarge.copyWith(color: Colors.white),
          ),

          content: TextField(
            cursorColor: Colors.white,
            controller: nameController,
            style: TextStyles.titleMedium.copyWith(color: Colors.white),
            maxLength: 40,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'0'))],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                LocaleKeys.cancel.tr(),
                style: TextStyles.titleLarge.copyWith(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  playlistBloc.add(CreatePlaylist(name));
                  for (var audio in selectedAudios) {
                    playlistBloc.add(AddAudioToPlaylist(name, audio));
                  }
                  playlistBloc.add(LoadPlaylists());

                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to previous page
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        LocaleKeys.playlistCreated.tr() + ': ' + name,
                      ),
                    ),
                  );
                }
              },
              child: Text(
                LocaleKeys.create.tr(),
                style: TextStyles.titleLarge.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
  );
}

Future<bool> showConfirmationDialog(
  BuildContext context,
  String message,
) async {
  return await showDialog<bool>(
        context: context,

        builder: (BuildContext dialogContext) {
          return AlertDialog(
            backgroundColor: globalBackgroundColor,
            title: Text(
              LocaleKeys.confirm.tr(),
              style: TextStyles.titleLarge.copyWith(color: Colors.white),
            ),
            content: Text(
              message,
              style: TextStyles.titleLarge.copyWith(color: Colors.white),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  LocaleKeys.cancel.tr(),
                  style: TextStyles.titleLarge.copyWith(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
              ),
              TextButton(
                child: Text(
                  LocaleKeys.ok.tr(),
                  style: TextStyles.titleLarge.copyWith(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
              ),
            ],
          );
        },
      ) ??
      false; // إذا أغلق المستخدم النافذة بدون اختيار
}

Future<void> confirmAndExecute({
  required BuildContext context,
  bool showSuccess = true,
  required String confirmMessage,
  required Future<void> Function() action,
  required String successMessage,
  required String errorMessage,
}) async {
  bool confirmed = await showConfirmationDialog(context, confirmMessage);

  if (confirmed) {
    try {
      await action();
      if (showSuccess)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }
}
