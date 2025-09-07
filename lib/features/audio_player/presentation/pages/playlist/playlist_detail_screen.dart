import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/audio_file.dart';
import '../../../domain/entities/playlist.dart';
import '../../cubit/audio_player/audio_player_cubit.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(playlist.name)),
      body:
          playlist.audios.isEmpty
              ? const Center(child: Text("No songs in this playlist"))
              : ListView.builder(
                itemCount: playlist.audios.length,
                itemBuilder: (context, index) {
                  final audio = playlist.audios[index];
                  return ListTile(
                    leading: const Icon(Icons.music_note),
                    title: Text(audio.title),
                    subtitle: Text(audio.artistOrUnknown),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {
                        // تشغيل الأغنية من Playlist
                        context.read<AudioPlayerCubit>().loadPlaylist(
                          playlist.audios,
                          startIndex: index,
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
