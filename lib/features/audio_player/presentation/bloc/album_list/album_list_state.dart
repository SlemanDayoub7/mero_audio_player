part of 'album_list_bloc.dart';

abstract class AlbumListState extends Equatable {
  const AlbumListState();
  @override
  List<Object> get props => [];
}

class AlbumListInitial extends AlbumListState {}

class AlbumListLoading extends AlbumListState {}

class AlbumListLoaded extends AlbumListState {
  final List<AlbumModel> Albums;
  const AlbumListLoaded({required this.Albums});
  @override
  List<Object> get props => [Albums];
}

class AlbumListError extends AlbumListState {
  final String message;
  const AlbumListError({required this.message});
  @override
  List<Object> get props => [message];
}

class SongsByAlbumLoading extends AlbumListState {}

class SongsByAlbumLoaded extends AlbumListState {
  final List<AudioFile> songs;
  const SongsByAlbumLoaded({required this.songs});
  @override
  List<Object> get props => [songs];
}

class SongsByAlbumError extends AlbumListState {
  final String message;
  const SongsByAlbumError({required this.message});
  @override
  List<Object> get props => [message];
}
