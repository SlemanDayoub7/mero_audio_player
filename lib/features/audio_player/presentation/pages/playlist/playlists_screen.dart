import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/playlist.dart';
import 'package:mero_audio_player/features/audio_player/presentation/cubit/audio_player/audio_player_cubit.dart';
import 'package:mero_audio_player/features/audio_player/presentation/cubit/playlist/playlist_cubit.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/playlist/create_playlist_screen.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/playlist/now_playing_screen.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/playlist/playlist_detail_screen.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Playlists")),
      body: BlocBuilder<PlaylistCubit, PlaylistState>(
        builder: (context, state) {
          if (state is PlaylistInitial)
            return const Center(child: CircularProgressIndicator());
          if (state is PlaylistsLoaded) {
            final playlists = state.playlists;
            if (playlists.isEmpty)
              return const Center(child: Text("No playlists yet"));

            return ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return ListTile(
                  title: Text(playlist.name),
                  subtitle: Text("${playlist.audios.length} songs"),
                  onTap: () {
                    // تشغيل أول أغنية من القائمة
                    context.read<AudioPlayerCubit>().loadPlaylist(
                      playlist.audios,
                      startIndex: 0,
                      autoRun: false,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => PlaylistDetailScreen(playlist: playlist),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed:
                        () =>
                            context.read<PlaylistCubit>().deletePlaylist(index),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePlaylistScreen()),
          );
        },
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final nameController = TextEditingController();
    final List<AudioFile> selectedSongs = [];

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Create Playlist"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Playlist Name"),
                ),
                const SizedBox(height: 10),
                // هنا ممكن تضيف قائمة لاختيار الأغاني من مكتبة المستخدم
                const Text("Add songs logic can be implemented here"),
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: const Text("Create"),
                onPressed: () {
                  final playlist = Playlist(
                    name: nameController.text,
                    audios: selectedSongs,
                  );
                  context.read<PlaylistCubit>().addPlaylist(playlist);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }
}
