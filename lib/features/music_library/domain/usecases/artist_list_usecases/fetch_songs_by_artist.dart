import 'package:mero_audio_player/features/music_library/domain/entities/audio_file/audio_file.dart';
import 'package:mero_audio_player/features/music_library/domain/repositories/audio_repository.dart';

class FetchSongsByArtist {
  final AudioRepository repository;

  FetchSongsByArtist(this.repository);

  Future<List<AudioFile>> call(String artistName) async {
    return await repository.fetchSongsByArtist(artistName);
  }
}
