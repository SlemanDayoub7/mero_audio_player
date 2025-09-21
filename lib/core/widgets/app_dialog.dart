import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/playlist/playlist_bloc.dart';
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
          title: Text(
            LocaleKeys.playlistName.tr(),
            style: TextStyles.titleLarge.copyWith(color: Colors.black),
          ),
          content: TextField(controller: nameController, maxLength: 40),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                LocaleKeys.cancel.tr(),
                style: TextStyles.titleLarge.copyWith(color: Colors.black),
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
                  Navigator.pop(context); // Close dialog
                  //    Navigator.pop(context); // Go back to previous page
                }
              },
              child: Text(
                LocaleKeys.create.tr(),
                style: TextStyles.titleLarge.copyWith(color: Colors.black),
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
            title: Text('تأكيد'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: const Text('إلغاء'),
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
              ),
              TextButton(
                child: const Text('موافق'),
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
  required String confirmMessage,
  required Future<void> Function() action,
  required String successMessage,
  required String errorMessage,
}) async {
  bool confirmed = await showConfirmationDialog(context, confirmMessage);

  if (confirmed) {
    try {
      await action();
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
