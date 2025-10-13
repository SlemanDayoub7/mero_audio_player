import 'package:audio_service/audio_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/audio_player/audio_player_bloc.dart';
import 'package:mero_audio_player/features/settings/presentation/pages/change_background/change_background_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/full_player_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/widgets/slider_progress.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/audio_art_work_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/control_icon_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/rotating_while_playing_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/waiting_list_widget.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';

class CurrentAudioWidget extends StatefulWidget {
  final double? controlIconsSize;
  const CurrentAudioWidget({super.key, this.controlIconsSize});

  @override
  State<CurrentAudioWidget> createState() => _CurrentAudioWidgetState();
}

class _CurrentAudioWidgetState extends State<CurrentAudioWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final audioBloc = context.read<AudioPlayerBloc>();
    final player = audioBloc.playerHandler.player;

    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        final current = state.current;
        if (current == null) return SizedBox.shrink();

        return InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => FullPlayerPage(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
              ),
              isScrollControlled:
                  true, // Allows full height bottom sheet if needed
            );
          },
          child: Container(
            padding: context.paddingMedium,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white, width: 0.5.r),
              ),
              //color: Colors.amber,
              gradient: gradientFromColor(globalBackgroundColor!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10.r,
                  offset: Offset(0, -3.h),
                ),
              ],

              //color: Colors.black,
            ),
            height: 94.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 5.w,
                  children: [
                    RotatingWhilePlayingWidget(
                      player: player,
                      child: AudioArtworkWidget(
                        backgroundColor: Colors.grey.withOpacity(0.4),
                        audio: state.current!,
                        showIconNullWidget: true,
                        size: 50.sp,
                      ),
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            current.title,
                            maxLines: 1,
                            style: TextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            current.artistOrUnknown,
                            style: TextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    ControlIconWidget(
                      opacity: 0,
                      rotate: context.locale.languageCode != 'ar',
                      svgGenImage: Assets.icons.next,
                      size: widget.controlIconsSize ?? 40.sp,
                      onPressed: () {
                        audioBloc.add(PreviousAudio());
                      },
                    ),

                    StreamBuilder<bool>(
                      stream: player.playingStream,
                      initialData: player.playing,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data ?? false;
                        return ControlIconWidget(
                          opacity: 0,
                          svgGenImage:
                              isPlaying
                                  ? Assets.icons.pause
                                  : Assets.icons.play,

                          size: widget.controlIconsSize ?? 40.sp,
                          onPressed: () {
                            if (isPlaying) {
                              audioBloc.add(PauseAudio());
                            } else {
                              //  if(player.pl==PlayerState.)
                              audioBloc.add(ResumeAudio());
                              // audioBloc.add(
                              //   PlayAudio(
                              //     audio: current,
                              //     audios: audioBloc.currentPlaylist,
                              //   ),
                              // );
                            }
                          },
                        );
                      },
                    ),
                    ControlIconWidget(
                      opacity: 0,
                      rotate: context.locale.languageCode == 'ar',
                      svgGenImage: Assets.icons.next,
                      size: widget.controlIconsSize ?? 40.sp,
                      onPressed: () {
                        audioBloc.add(NextAudio());
                      },
                    ),
                    WaitingListWidget(
                      audioBloc: audioBloc,
                      showTitle: false,
                      size: 40.sp,
                    ),
                  ],
                ),
                StreamBuilder<Duration>(
                  stream: player.positionStream,
                  builder: (context, snapshot) {
                    return SliderProgress(
                      trackHeight: 3.h,
                      enabledThumbRadius: 4.r,
                      padding: EdgeInsetsDirectional.only(start: 65.w),
                      position: snapshot.data ?? Duration(seconds: 0),
                      duration: Duration(milliseconds: current.duration!),
                      onSeek: (duration) => player.seek(duration),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
