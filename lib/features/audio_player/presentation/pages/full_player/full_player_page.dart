import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
import 'package:mero_audio_player/core/themes/app_background_image.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/features/audio_player/presentation/change_background_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/current_audio_detail/widgets/audio_title_marquee.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/current_audio_detail/widgets/slider_progress.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/widgets/speed_drop_down.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/add_to_favorite_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/audio_art_work_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/waiting_list_widget.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';
import 'package:mero_audio_player/injection.dart';
import '../../bloc/audio_player/audio_player_bloc.dart';

class FullPlayerPage extends StatelessWidget {
  const FullPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final audioBloc = context.read<AudioPlayerBloc>();
    final player = audioBloc.playerHandler.player;

    return Scaffold(
      body: Stack(
        children: [
          AppBackgroundImage(isForPlayer: true),
          BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
            builder: (context, state) {
              final current = state.current;
              if (current == null) return const SizedBox.shrink();

              return Column(
                children: [
                  context.emptySizedHeightMedium,
                  // 🔹 1. الشريط العلوي
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      children: [
                        ControlIconWidget(
                          icon: Icons.arrow_back,
                          size: 35.sp,
                          opacity: 0,
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            current.artistOrUnknown,
                            style: TextStyles.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        AddToFavoriteWidget(audioFile: current),
                      ],
                    ),
                  ),

                  // 🔹 2. Artwork / لوتى
                  Expanded(
                    flex: 4,
                    child: StreamBuilder<bool>(
                      stream: player.playingStream,
                      initialData: player.playing,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data ?? false;
                        return Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Lottie.asset(
                                globalLottiePath,
                                animate: isPlaying,
                                height: 420.h,
                              ),
                              AudioArtworkWidget(
                                audio: current,
                                size: 100.r,
                                borderRadius: 100.r,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // 🔹 3. عنوان + ألبوم + Slider
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AudioTitleMarquee(audioTitle: current.title),
                          Text(
                            current.album ?? '',
                            style: TextStyles.displaySmall.copyWith(
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                          StreamBuilder<Duration>(
                            stream: player.positionStream,
                            builder: (context, snapshot) {
                              return Column(
                                children: [
                                  SliderProgress(
                                    trackHeight: 4.h,
                                    enabledThumbRadius: 6.r,
                                    position: snapshot.data ?? Duration.zero,
                                    duration: Duration(
                                      milliseconds: current.duration ?? 0,
                                    ),
                                    onSeek: (duration) => player.seek(duration),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        _fmt(snapshot.data ?? Duration.zero),
                                        style: TextStyles.headlineMedium
                                            .copyWith(color: Colors.white),
                                      ),
                                      const Spacer(),
                                      Text(
                                        _fmt(
                                          Duration(
                                            milliseconds: current.duration ?? 0,
                                          ),
                                        ),
                                        style: TextStyles.headlineMedium
                                            .copyWith(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 🔹 4. أزرار التحكم الكبيرة
                  Expanded(
                    flex: 1,
                    child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
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
                                    audioBloc.add(
                                      SeekAudio(Duration(seconds: a)),
                                    );
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
                                      isPlaying
                                          ? Assets.icons.pause
                                          : Assets.icons.play,
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
                                    audioBloc.add(
                                      SeekAudio(Duration(seconds: a)),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // 🔹 5. سرعة + مود التشغيل + الانتظار
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SpeedDropdown(
                              currentSpeed: audioBloc.state.speed,
                              onChanged:
                                  (value) =>
                                      audioBloc.add(SetPlaybackSpeed(value)),
                            ),
                            DropdownButton<PlaybackMode>(
                              underline: const SizedBox.shrink(),
                              dropdownColor: globalBackgroundColor,
                              value: playbackMode,
                              icon:
                                  playbackMode == PlaybackMode.shuffle
                                      ? Assets.icons.shuffle.svg(
                                        color: Colors.white,
                                        width: 30.sp,
                                        height: 30.sp,
                                      )
                                      : playbackMode == PlaybackMode.repeatOne
                                      ? Assets.icons.repeateOne.svg(
                                        color: Colors.white,
                                        width: 30.sp,
                                        height: 30.sp,
                                      )
                                      : Assets.icons.repeate.svg(
                                        color: Colors.white,
                                        width: 30.sp,
                                        height: 30.sp,
                                      ),
                              items:
                                  PlaybackMode.values.map((type) {
                                    String label;
                                    switch (type) {
                                      case PlaybackMode.repeatAll:
                                        label = LocaleKeys.repeatAll.tr();
                                        break;
                                      case PlaybackMode.repeatOne:
                                        label = LocaleKeys.repeatCurrent.tr();
                                        break;
                                      case PlaybackMode.shuffle:
                                        label = LocaleKeys.shuffle.tr();
                                        break;
                                    }
                                    return DropdownMenuItem<PlaybackMode>(
                                      value: type,
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.only(
                                          end: 3.w,
                                        ),
                                        child: Text(
                                          label,
                                          style: TextStyles.titleMedium
                                              .copyWith(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (newPlaybackMode) {
                                playbackMode = newPlaybackMode!;
                                audioBloc.add(
                                  TogglePlaybackMode(
                                    playbackMode: newPlaybackMode,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: WaitingListWidget(audioBloc: audioBloc),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "${h == 0 ? '' : ('$h:')}$m:$s";
  }
}

class ControlIconWidget extends StatelessWidget {
  final IconData? icon;
  final double? size;
  final SvgGenImage? svgGenImage;
  final Color? color;
  final Function()? onPressed;
  final double? opacity;
  final bool? rotate;
  final Color? borderColor;
  const ControlIconWidget({
    super.key,
    this.svgGenImage,
    this.icon,
    this.size,
    this.onPressed,
    this.opacity,
    this.color,
    this.rotate = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      splashColor: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(100.r),
      child: RotatedBox(
        quarterTurns: rotate! ? 2 : 0,
        child: Container(
          padding: EdgeInsets.all(6.w),
          width: (size ?? 45.w),
          height: (size ?? 45.w),
          decoration: BoxDecoration(
            border:
                borderColor != null ? Border.all(color: borderColor!) : null,
            shape: BoxShape.circle,
            color: (globalBackgroundColor ?? Colors.black).withOpacity(
              opacity ?? 0.5,
            ),
          ),
          child:
              svgGenImage != null
                  ? svgGenImage!.svg(
                    color: color ?? Colors.white,
                    width: (size ?? 45.w),
                    height: (size ?? 45.w),
                  )
                  : Icon(
                    icon,
                    size: size ?? 40.sp,
                    color: color ?? Colors.white,
                  ),
        ),
      ),
    );
  }
}
