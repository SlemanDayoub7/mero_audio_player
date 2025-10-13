import 'package:mero_audio_player/features/music_library/domain/entities/audio_file/audio_file.dart';
import 'package:mero_audio_player/features/music_library/domain/repositories/audio_repository.dart';

class FetchSongsByAlbum {
  final AudioRepository repository;

  FetchSongsByAlbum(this.repository);

  Future<List<AudioFile>> call(String albumName) async {
    return await repository.fetchSongsByAlbum(albumName);
  }
}
