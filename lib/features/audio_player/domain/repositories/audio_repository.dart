import 'package:mero_audio_player/features/audio_player/domain/entities/artwork.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
import 'package:on_audio_query/on_audio_query.dart';

abstract class AudioRepository {
  // جلب كل الملفات الموسيقية
  Future<List<AudioFile>> fetchAudioFiles();

  // جلب كل الفنانين
  Future<List<ArtistModel>> fetchArtists();

  // جلب كل الألبومات
  Future<List<AlbumModel>> fetchAlbums();

  // جلب أغاني لفنان معين
  Future<List<AudioFile>> fetchSongsByArtist(String artistName);

  // جلب أغاني من ألبوم معين
  Future<List<AudioFile>> fetchSongsByAlbum(String albumName);
}
