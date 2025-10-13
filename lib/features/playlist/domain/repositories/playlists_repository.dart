import 'package:mero_audio_player/features/music_library/domain/entities/audio_file/audio_file.dart';
import 'package:mero_audio_player/features/playlist/domain/entities/playlist/playlist.dart';

abstract class PlaylistRepository {
  Future<List<Playlist>> getAllPlaylists();
  Future<void> createPlaylist(Playlist playlist);
  Future<void> addAudioToPlaylist(String playlistName, AudioFile audio);
  Future<void> removeAudioFromPlaylist(String playlistName, AudioFile audio);
  Future<void> deletePlaylist(String playlistName);
}
