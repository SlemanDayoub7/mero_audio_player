import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_dialog.dart';
import 'package:mero_audio_player/features/music_library/domain/entities/audio_file/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/recently_played/recently_played_event.dart';
import 'package:mero_audio_player/features/music_library/presentation/bloc/album_list/album_list_bloc.dart';
import 'package:mero_audio_player/features/music_library/presentation/bloc/artist_list/artist_list_bloc.dart';
import 'package:mero_audio_player/features/music_library/presentation/bloc/audio_list/audio_list_bloc.dart';
import 'package:mero_audio_player/features/playlist/presentation/bloc/playlist_bloc.dart';
import 'package:mero_audio_player/features/ringtone/presentation/bloc/ringtone_bloc.dart';
import 'package:mero_audio_player/features/settings/presentation/pages/change_background/change_background_page.dart';
import 'package:mero_audio_player/features/playlist/presentation/pages/add_to_playlist_page.dart';
import 'package:mero_audio_player/features/ringtone/presentation/pages/set_ringtone_page.dart';
import 'package:mero_audio_player/core/services/media_store_service.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';
import 'package:mero_audio_player/main.dart';
import 'package:ringtone_set_plus/ringtone_set_plus.dart';

void showAudioOptionsBottomSheet(
  BuildContext context,
  AudioFile audio,
  PlaySource playSource, {
  VoidCallback? onDelete,
  String? playlistName,
  String? artistName,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: globalBackgroundColor,
    isScrollControlled: true,
    constraints: BoxConstraints(maxHeight: 300.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
    ),
    builder:
        (context) => AudioOptionsSheet(
          audio: audio,
          playSource: playSource,
          playlistName: playlistName,
          artistName: artistName,
          onDelete: onDelete,
        ),
  );
}

class AudioOptionsSheet extends StatelessWidget {
  final PlaySource playSource;
  final String? playlistName;
  final String? artistName;
  final AudioFile audio;
  final VoidCallback? onDelete;
  const AudioOptionsSheet({
    super.key,
    required this.audio,
    required this.playSource,
    this.playlistName,
    this.artistName,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
        gradient: gradientFromColor(
          globalBackgroundColor ?? Colors.black,
        ), // assuming gradient getter
      ),
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      child: Column(
        spacing: 20.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(
            context,
            text: LocaleKeys.addToPlaylist.tr(),
            icon: Assets.icons.playlistAdd,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddToPlaylistPage(audios: [audio]),
                ),
              );
            },
          ),

          // SizedBox(height: 10.h),
          // _buildOption(
          //   context,
          //   text: LocaleKeys.cutChapter.tr(),
          //   icon: Assets.icons.cut,
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) => CreateAudiobookPage(audioFile: audio),
          //       ),
          //     );
          //   },
          // ),
          _buildOption(
            context,
            text:
                LocaleKeys.delete
                    .tr(), // or LocaleKeys.delete.tr() if you have it localized
            icon: Assets.icons.removeAll, // put your delete icon asset here
            onTap: () async {
              // Ask the user for confirmation first
              if (playSource == PlaySource.playlist) {
                await confirmAndExecute(
                  context: context,
                  confirmMessage:
                      LocaleKeys.file_will_be_removed_from_playlist.tr(),
                  action: () async {
                    context.read<PlaylistBloc>().add(
                      RemoveAudioFromPlaylist(playlistName!, audio),
                    );
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  successMessage: LocaleKeys.file_removed_from_playlist.tr(),
                  errorMessage: LocaleKeys.delete_error.tr(),
                );
              } else {
                await confirmAndExecute(
                  context: context,
                  showSuccess: false,
                  confirmMessage:
                      LocaleKeys.delete_confirmation.tr(), // localize if needed
                  errorMessage: LocaleKeys.delete_error.tr(),
                  successMessage: LocaleKeys.delete_success.tr(),
                  action: () async {
                    await deleteAudioFileFromMediaStore(audio.uri ?? '');
                    context.read<PlaylistBloc>().add(LoadPlaylists());
                    onDelete?.call();
                    context.read<ArtistListBloc>().add(FetchArtistList());
                    context.read<AudioListBloc>().add(FetchAudioList());
                    context.read<AlbumListBloc>().add(FetchAlbumList());
                    Navigator.pop(context);
                  },
                );

                // Close the bottom sheet after deletion
              }
            },
          ),

          _buildOption(
            context,
            text: LocaleKeys.setRingtone.tr(),
            icon: Assets.icons.ringtone,
            onTap: () async {
              if (!(await RingtoneSet.isWriteSettingsGranted)) {
                permissionCompleter = Completer<bool>();
                await SystemSettings.openWriteSettings();
                // Now wait for user to return and permission to be rechecked
                return permissionCompleter!.future.then((granted) async {
                  if (!granted) return;

                  bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BlocProvider<SetRingToneBloc>(
                            create: (context) => SetRingToneBloc(),
                            child: SetRingtonePage(audioFile: audio),
                          ),
                    ),
                  );
                  if (result == true) {
                    context.read<AlbumListBloc>().add(FetchAlbumList());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(LocaleKeys.ringtoneSet.tr())),
                    );
                  }

                  Navigator.pop(context);
                });
              } else {
                // Permission already granted, proceed immediately
                bool? result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => BlocProvider<SetRingToneBloc>(
                          create: (context) => SetRingToneBloc(),
                          child: SetRingtonePage(audioFile: audio),
                        ),
                  ),
                );
                if (result == true) {
                  // context.read<PlaylistBloc>().add(LoadPlaylists());
                  // context.read<ArtistListBloc>().add(FetchArtistList());
                  // context.read<AudioListBloc>().add(FetchAudioList());
                  // context.read<AlbumListBloc>().add(FetchAlbumList());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(LocaleKeys.ringtoneSet.tr())),
                  );
                }

                Navigator.pop(context);
              }
            },
          ),

          // _buildOption(
          //   context,
          //   text: LocaleKeys.setNotificationTone.tr(),
          //   icon: Assets.icons.notificationRing,
          //   onTap: () async {
          //     await confirmAndExecute(
          //       context: context,
          //       confirmMessage:
          //           LocaleKeys.currentAudioWillBeNotificationTone.tr(),
          //       errorMessage: '',
          //       successMessage: LocaleKeys.fileSetAsNotificationTone.tr(),
          //       action: () async {
          //         bool success = false;
          //         try {
          //           success = await RingtoneSet.setNotificationFromFile(
          //             File(audio.data ?? ''),
          //           );
          //         } on PlatformException {
          //           success = false;
          //         }
          //       },
          //     );
          //     Navigator.pop(context);
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String text,
    required SvgGenImage icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        spacing: 7.w,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          icon.svg(width: 30.w, height: 30.w, color: Colors.white),
          Text(
            text,
            style: TextStyles.headlineMedium.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

final mediaStore = MediaStore();

Future<void> deleteAudioFileFromMediaStore(String path) async {
  final deleted = await mediaStore.deleteFileUsingUri(uriString: path);
  if (deleted) {
  } else {}
}

Future<bool> requestWriteSettingsPermission() async {
  if (!(await RingtoneSet.isWriteSettingsGranted)) {
    // Permission permanently denied, open app settings for manual enable
    // await openAppSettings();
    await SystemSettings.openWriteSettings().then((_) {
      // You can add more logic here after the settings screen is opened,
      // but note this does NOT wait for user action or permission grant.
    });
  }

  return await RingtoneSet.isWriteSettingsGranted;
}
