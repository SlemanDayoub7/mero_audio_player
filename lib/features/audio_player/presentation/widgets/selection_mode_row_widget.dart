import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_dialog.dart';
import 'package:mero_audio_player/features/music_library/domain/entities/audio_file/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/recently_played/recently_played_event.dart';
import 'package:mero_audio_player/features/playlist/presentation/bloc/playlist_bloc.dart';
import 'package:mero_audio_player/features/settings/presentation/pages/change_background/change_background_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/full_player_page.dart';
import 'package:mero_audio_player/features/playlist/presentation/pages/add_to_playlist_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/control_icon_widget.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';
import 'package:share_plus/share_plus.dart';

class SelectionModeRowWidget extends StatelessWidget {
  final Function() onSelectAll;
  final Set<AudioFile> selected;
  final int audiosLength;
  final String? playlistName;
  final double? bottomMargin;
  final PlaySource? playSource;
  final Function()? onDelete;
  const SelectionModeRowWidget({
    super.key,
    required this.onSelectAll,
    required this.selected,
    required this.audiosLength,
    this.bottomMargin,
    this.playSource = PlaySource.artist,
    this.onDelete,
    this.playlistName,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(bottom: bottomMargin ?? 94.h),
        decoration: BoxDecoration(color: globalBackgroundColor),
        height: 70.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            context.emptySizedWidthLow,
            InkWell(
              onTap: onSelectAll,
              child: Center(
                child: Text(
                  selected.length == audiosLength
                      ? LocaleKeys.deselect_all.tr()
                      : LocaleKeys.selectAll.tr(),
                  style: TextStyles.titleLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
            Center(
              child: Text(
                '${selected.length > 999999 ? "+999999" : selected.length} ${LocaleKeys.selected.tr()}',
                style: TextStyles.titleLarge.copyWith(color: Colors.white),
              ),
            ),
            ControlIconWidget(
              size: 35.sp,
              svgGenImage: Assets.icons.share,
              onPressed: () async {
                final files = selected.map((a) => XFile(a.data ?? '')).toList();

                await Share.shareXFiles(
                  files,
                  text: LocaleKeys.share_audio_clips.tr(),
                );
              },
            ),
            ControlIconWidget(
              size: 35.sp,
              svgGenImage: Assets.icons.playlistAdd,

              opacity: 0,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            AddToPlaylistPage(audios: selected.toList()),
                  ),
                );
              },
            ),

            if (playlistName != null)
              ControlIconWidget(
                size: 35.sp,
                svgGenImage: Assets.icons.removeAll,
                opacity: 0,
                onPressed: () async {
                  await confirmAndExecute(
                    context: context,
                    showSuccess: false,
                    confirmMessage:
                        LocaleKeys.delete_files_playlist
                            .tr(), // localize if needed
                    errorMessage: LocaleKeys.delete_error.tr(),
                    successMessage: LocaleKeys.files_deleted_success.tr(),
                    action: () async {
                      selected.forEach(
                        (audio) => context.read<PlaylistBloc>().add(
                          RemoveAudioFromPlaylist(playlistName!, audio),
                        ),
                      );
                      Navigator.pop(context);
                      selected.clear();
                    },
                  );
                },
              ),
            context.emptySizedWidthLow,
          ],
        ),
      ),
    );
  }
}

final mediaStore = MediaStore();

Future<void> deleteMultipleAudioFiles(List<String> paths) async {
  await Future.wait(
    paths.map((path) async {
      final deleted = await mediaStore.deleteFileUsingUri(uriString: path);
      if (deleted) {
      } else {}
    }),
  );
}
