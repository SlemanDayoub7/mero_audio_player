import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/themes/color_util.dart'; // For gradient colors utility
import 'package:mero_audio_player/features/audio_player/presentation/cubit/audio_player/audio_player_cubit.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/current_audio_detail/current_audio_detail_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/audio_art_work_widget.dart';

class CurrentAudioWidget extends StatelessWidget {
  const CurrentAudioWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, state) {
        if (state is! AudioPlayerPlaying && state is! AudioPlayerPaused) {
          return const SizedBox.shrink();
        }

        final audio =
            state is AudioPlayerPlaying
                ? state.audio
                : (state as AudioPlayerPaused).audio;
        final pos =
            state is AudioPlayerPlaying
                ? state.position
                : (state as AudioPlayerPaused).position;
        final dur =
            state is AudioPlayerPlaying
                ? state.duration
                : (state as AudioPlayerPaused).duration;
        final isPlaying = state is AudioPlayerPlaying;

        final bgGradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ColorUtil.getGradientColorsFromId(audio.id.toString()),
        );

        return InkWell(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CurrentAudioDetailPage(),
                ),
              ),
          child: Container(
            height: 100.h,
            padding: EdgeInsets.all(10.w),
            margin: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              gradient: bgGradient,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    AudioArtworkWidget(audio: audio),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            audio.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            audio.artist ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                      ),
                      onPressed:
                          () => context.read<AudioPlayerCubit>().previous(),
                    ),
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        isPlaying
                            ? context.read<AudioPlayerCubit>().pause()
                            : context.read<AudioPlayerCubit>().play();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      onPressed: () => context.read<AudioPlayerCubit>().next(),
                    ),
                  ],
                ),
                Slider(
                  thumbColor: theme.colorScheme.primary,
                  activeColor: Colors.blue,
                  padding: EdgeInsets.zero,
                  value: pos.inSeconds.toDouble(),
                  max:
                      dur.inSeconds.toDouble() > 0
                          ? dur.inSeconds.toDouble()
                          : 1,
                  onChanged:
                      (v) => context.read<AudioPlayerCubit>().seek(
                        Duration(seconds: v.toInt()),
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
