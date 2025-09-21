import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/audio_player/audio_player_bloc.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';

class MiniMusicVisualizerWidget extends StatelessWidget {
  final int id;
  const MiniMusicVisualizerWidget({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final audioBloc = context.read<AudioPlayerBloc>();
    final player = audioBloc.playerHandler.player;
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (state.current == null) return SizedBox.shrink();
        return StreamBuilder<bool>(
          stream: player.playingStream,
          initialData: player.playing,

          builder: (context, snapshot) {
            final isPlaying = snapshot.data ?? false;
            return (isPlaying && state.current!.id == id)
                ? MiniMusicVisualizer(
                  animate: true,
                  color: Colors.white,
                  width: 8.w,
                  radius: 45.r,
                  height: 30.h,
                )
                : SizedBox.shrink();
          },
        );
      },
    );
  }
}
