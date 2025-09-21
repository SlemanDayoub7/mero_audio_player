part of 'artist_list_bloc.dart';

abstract class ArtistListEvent extends Equatable {
  const ArtistListEvent();
  @override
  List<Object> get props => [];
}

class FetchArtistList extends ArtistListEvent {}

class SearchArtist extends ArtistListEvent {
  final String query;
  const SearchArtist({required this.query});
  @override
  List<Object> get props => [query];
}

class FetchSongsByArtist extends ArtistListEvent {
  final String artistName;
  const FetchSongsByArtist({required this.artistName});
  @override
  List<Object> get props => [artistName];
}
