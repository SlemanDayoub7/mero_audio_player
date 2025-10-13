import 'package:on_audio_query/on_audio_query.dart';

class SearchArtists {
  const SearchArtists();

  List<ArtistModel> call(List<ArtistModel> artists, String query) {
    final lower = query.toLowerCase();
    return artists
        .where((artist) => artist.artist.toLowerCase().contains(lower))
        .toList();
  }
}
