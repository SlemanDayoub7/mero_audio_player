part of 'album_list_bloc.dart';

abstract class AlbumListEvent extends Equatable {
  const AlbumListEvent();
  @override
  List<Object> get props => [];
}

class FetchAlbumList extends AlbumListEvent {}

class SearchAlbum extends AlbumListEvent {
  final String query;
  const SearchAlbum({required this.query});
  @override
  List<Object> get props => [query];
}

class FetchSongsByAlbum extends AlbumListEvent {
  final String AlbumName;
  const FetchSongsByAlbum({required this.AlbumName});
  @override
  List<Object> get props => [AlbumName];
}
