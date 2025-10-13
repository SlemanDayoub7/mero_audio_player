import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:mero_audio_player/features/music_library/domain/entities/audio_file/audio_file.dart';
import 'package:mero_audio_player/features/settings/presentation/pages/change_background/change_background_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/audio_art_work_widget.dart';

class ArtworkPlayerWidget extends StatelessWidget {
  const ArtworkPlayerWidget({
    super.key,
    required this.player,
    required this.current,
  });

  final AudioPlayer player;
  final AudioFile current;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: player.playingStream,
      initialData: player.playing,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;
        return Center(
          child: SizedBox(
            width: 1.sw,
            height: 1.sw,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // AudioArtworkWidget(
                //   audio: current,
                //   showNullWidget: false,
                //   size: 0.9.sw,
                //   borderRadius: 0.9.sw,
                // ),
                Lottie.asset(
                  globalLottiePath,
                  animate: isPlaying,
                  height: 1.sw,
                  width: 1.sw,
                ),
                AudioArtworkWidget(
                  audio: current,
                  size: 150.r,
                  showIconNullWidget: true,
                  borderRadius: 100.r,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
