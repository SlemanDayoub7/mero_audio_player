import 'package:mero_audio_player/features/music_library/domain/entities/audio_file/audio_file.dart';
import 'package:on_audio_query/on_audio_query.dart';

abstract class AudioRepository {
  Future<List<AudioFile>> fetchAudioFiles();

  Future<List<ArtistModel>> fetchArtists();

  Future<List<AlbumModel>> fetchAlbums();

  Future<List<AudioFile>> fetchSongsByArtist(String artistName);
  Future<List<AudioFile>> fetchSongsByAlbum(String albumName);
}
