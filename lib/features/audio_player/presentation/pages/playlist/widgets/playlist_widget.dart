import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_dialog.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/playlist.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/full_player_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/playlist/playlist_detail_page.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';

class PlaylistWidget extends StatelessWidget {
  const PlaylistWidget({super.key, required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlaylistDetailPage(playlist: playlist),
          ),
        );
      },
      child: Row(
        children: [
          // Assets.icons.playlist.svg(
          //   width: 40.sp,
          //   height: 40.sp,
          //   color: Colors.white,
          // ),

          // SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playlist.name,
                  maxLines: 1,
                  style: TextStyles.titleLarge.copyWith(color: Colors.white),
                ),
                Text(
                  "${playlist.audios.length} ${LocaleKeys.audioPlural.tr()}",
                  style: TextStyles.titleMedium.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          ControlIconWidget(
            svgGenImage: Assets.icons.deletePlaylist,
            size: 35.sp,
            onPressed: () async {
              await confirmAndExecute(
                context: context,
                confirmMessage: 'هل أنت متأكد من حذف قائمة التشغيل؟',
                action:
                    () async => context.read<PlaylistBloc>().add(
                      DeletePlaylist(playlist.name),
                    ),
                successMessage: 'تم حذف الفائمة',
                errorMessage: 'error',
              );
            },
          ),
        ],
      ),
    );
  }
}
