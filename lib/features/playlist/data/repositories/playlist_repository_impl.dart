import 'package:hive_flutter/hive_flutter.dart';
import 'package:mero_audio_player/features/music_library/domain/entities/audio_file/audio_file.dart';
import 'package:mero_audio_player/features/playlist/domain/entities/playlist/playlist.dart';
import 'package:mero_audio_player/features/playlist/domain/repositories/playlists_repository.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final Box<Playlist> _box = Hive.box<Playlist>('playlists');

  @override
  Future<List<Playlist>> getAllPlaylists() async => _box.values.toList();

  @override
  Future<void> createPlaylist(Playlist playlist) async {
    await _box.put(playlist.name, playlist);
  }

  @override
  Future<void> addAudioToPlaylist(String playlistName, AudioFile audio) async {
    final playlist = _box.get(playlistName);

    if (playlist != null && !playlist.audios.any((a) => a.id == audio.id)) {
      playlist.audios.add(audio);
      await playlist.save();
    }
  }

  @override
  Future<void> removeAudioFromPlaylist(
    String playlistName,
    AudioFile audio,
  ) async {
    final playlist = _box.get(playlistName);
    if (playlist != null) {
      playlist.audios.removeWhere((a) => a.id == audio.id);
      await playlist.save();
    }
  }

  @override
  Future<void> deletePlaylist(String playlistName) async {
    await _box.delete(playlistName);
  }
}
