import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/recently_played_event.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/audio_list/audio_list_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/audio_player/audio_player_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/ringtone/ringtone_bloc.dart';

import 'package:mero_audio_player/features/audio_player/presentation/pages/ringtone/set_ringtone_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/audio_art_work_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/audio_options_sheet.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/mini_music_visualizer_widget.dart';

class AudioWidget extends StatelessWidget {
  const AudioWidget({
    super.key,
    required this.audio,
    this.audios = const [],
    this.artist,
    this.playListName,
    this.isSelected = false,
    this.onLongPress,
    this.onTap,
    this.selectionMode = false,
    required this.playSource,
    this.onDelete,
    this.showOptions = true,
  });

  final List<AudioFile>? audios;
  final AudioFile audio;
  final String? artist;
  final String? playListName;
  final bool? selectionMode;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final PlaySource playSource;
  final bool? showOptions;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          onTap ??
          () {
            context.read<AudioPlayerBloc>().add(
              audios!.isEmpty
                  ? PlayAudio(
                    audio: audio,
                    audios: context.read<AudioListBloc>().fullList,
                  )
                  : PlayAudio(audio: audio, audios: audios!),
            );
          },
      onLongPress: onLongPress,
      child: Container(
        color:
            isSelected
                ? Colors.blue.withOpacity(0.3) // لون خلفية عند التحديد
                : Colors.transparent,
        height: 65.h,
        padding: context.paddingLow,
        child: Row(
          spacing: 3.w,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AudioArtworkWidget(audio: audio, size: 50.r),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    audio.title,
                    maxLines: 1,
                    style: TextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    audio.artistOrUnknown,
                    maxLines: 1,
                    style: TextStyles.bodyMedium.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            MiniMusicVisualizerWidget(id: audio.id),
            (!showOptions! || selectionMode!)
                ? SizedBox.shrink()
                : IconButton(
                  onPressed: () {
                    showAudioOptionsBottomSheet(
                      context,
                      audio,
                      playSource,
                      onDelete: onDelete,
                      artistName: artist,
                      playlistName: playListName,
                    );
                  },
                  icon: Icon(Icons.more_vert, color: Colors.white),
                ),
          ],
        ),
      ),
    );
  }
}
