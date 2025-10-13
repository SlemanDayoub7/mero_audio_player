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

class FetchSongsByAlbumEvent extends AlbumListEvent {
  final String albumName;
  const FetchSongsByAlbumEvent({required this.albumName});
  @override
  List<Object> get props => [albumName];
}
