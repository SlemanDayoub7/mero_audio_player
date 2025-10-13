import 'package:mero_audio_player/features/music_library/domain/repositories/audio_repository.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FetchAlbums {
  final AudioRepository repository;

  FetchAlbums(this.repository);

  Future<List<AlbumModel>> call() async {
    return await repository.fetchAlbums();
  }
}
