import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mero_audio_player/features/music_library/domain/entities/audio_file/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/audio_player/audio_player_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/control_icon_widget.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';

class PlayerControlsBlocBuilder extends StatelessWidget {
  const PlayerControlsBlocBuilder({
    super.key,
    required this.player,
    required this.audioBloc,
    required this.current,
  });

  final AudioPlayer player;
  final AudioPlayerBloc audioBloc;
  final AudioFile current;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // -10s
            StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, snapshot) {
                return ControlIconWidget(
                  svgGenImage:
                      context.locale.languageCode != 'ar'
                          ? Assets.icons.backward10Second
                          : Assets.icons.forward10Seconds,
                  opacity: 0,
                  onPressed: () {
                    int a =
                        ((snapshot.data ?? Duration.zero) -
                                const Duration(seconds: 10))
                            .inSeconds;
                    if (a < 0) a = 0;
                    audioBloc.add(SeekAudio(Duration(seconds: a)));
                  },
                );
              },
            ),

            ControlIconWidget(
              rotate: context.locale.languageCode != 'ar',
              opacity: 0.8,
              svgGenImage: Assets.icons.next,
              onPressed: () => audioBloc.add(PreviousAudio()),
            ),

            StreamBuilder<bool>(
              stream: player.playingStream,
              initialData: player.playing,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data ?? false;
                return ControlIconWidget(
                  onPressed: () {
                    if (isPlaying) {
                      audioBloc.add(PauseAudio());
                    } else {
                      audioBloc.add(ResumeAudio());
                    }
                  },
                  size: 65.sp,
                  opacity: 0.8,
                  svgGenImage:
                      isPlaying ? Assets.icons.pause : Assets.icons.play,
                );
              },
            ),
            ControlIconWidget(
              opacity: 0.8,
              svgGenImage: Assets.icons.next,
              rotate: context.locale.languageCode == 'ar',
              onPressed: () => audioBloc.add(NextAudio()),
            ),
            StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, snapshot) {
                return ControlIconWidget(
                  svgGenImage:
                      context.locale.languageCode == 'ar'
                          ? Assets.icons.backward10Second
                          : Assets.icons.forward10Seconds,
                  opacity: 0,
                  onPressed: () {
                    int a =
                        ((snapshot.data ?? Duration.zero) +
                                const Duration(seconds: 10))
                            .inSeconds;
                    if (a > (current.duration ?? 0)) {
                      a = (current.duration ?? 0);
                    }
                    audioBloc.add(SeekAudio(Duration(seconds: a)));
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
