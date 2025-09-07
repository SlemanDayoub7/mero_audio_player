import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../domain/entities/audio_file.dart';
import '../../../domain/entities/playlist.dart';
import '../../cubit/playlist/playlist_cubit.dart';

class CreatePlaylistScreen extends StatefulWidget {
  const CreatePlaylistScreen({super.key});

  @override
  State<CreatePlaylistScreen> createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<AudioFile> _selectedSongs = [];
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> _allSongs = [];

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  void _fetchSongs() async {
    // طلب صلاحيات الوصول للأغاني
    bool permission = await _audioQuery.permissionsStatus();
    if (!permission) {
      permission = await _audioQuery.permissionsRequest();
    }

    if (permission) {
      final songs = await _audioQuery.querySongs();
      setState(() => _allSongs = songs);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Playlist")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Playlist Name"),
            ),
          ),
          Expanded(
            child:
                _allSongs.isEmpty
                    ? const Center(child: Text("No songs found"))
                    : ListView.builder(
                      itemCount: _allSongs.length,
                      itemBuilder: (context, index) {
                        final song = _allSongs[index];
                        final isSelected = _selectedSongs.any(
                          (s) => s.id == song.id,
                        );
                        return ListTile(
                          title: Text(song.title),
                          subtitle: Text(song.artist ?? "Unknown Artist"),
                          trailing: Checkbox(
                            value: isSelected,
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  _selectedSongs.add(
                                    AudioFile.fromSongModel(song),
                                  );
                                } else {
                                  _selectedSongs.removeWhere(
                                    (s) => s.id == song.id,
                                  );
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              child: const Text("Create Playlist"),
              onPressed: () {
                if (_nameController.text.isEmpty || _selectedSongs.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter name & select songs")),
                  );
                  return;
                }
                final playlist = Playlist(
                  name: _nameController.text,
                  audios: _selectedSongs,
                );
                context.read<PlaylistCubit>().addPlaylist(playlist);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
