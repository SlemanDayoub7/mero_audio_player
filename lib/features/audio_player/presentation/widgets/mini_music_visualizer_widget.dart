import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/cubit/audio_player/audio_player_cubit.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';

class MiniMusicVisualizerWidget extends StatelessWidget {
  final int id;
  const MiniMusicVisualizerWidget({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, state) {
        if (state is AudioPlayerPlaying && state.audio.id == id) {
          return MiniMusicVisualizer(
            animate: true,
            color: Colors.blue,
            width: 4,
            height: 15,
          );
        }
        return SizedBox();
      },
    );
  }
}
