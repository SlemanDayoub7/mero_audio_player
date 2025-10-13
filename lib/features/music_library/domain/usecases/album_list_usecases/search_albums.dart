import 'package:on_audio_query/on_audio_query.dart';

class SearchAlbums {
  const SearchAlbums();

  List<AlbumModel> call(List<AlbumModel> albums, String query) {
    final lower = query.toLowerCase();
    return albums
        .where((album) => album.album.toLowerCase().contains(lower))
        .toList();
  }
}
