import 'package:mero_audio_player/features/music_library/domain/repositories/audio_repository.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FetchArtists {
  final AudioRepository repository;

  FetchArtists(this.repository);

  Future<List<ArtistModel>> call() async {
    return await repository.fetchArtists();
  }
}
