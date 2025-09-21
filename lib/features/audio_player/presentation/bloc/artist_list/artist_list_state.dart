part of 'artist_list_bloc.dart';

abstract class ArtistListState extends Equatable {
  const ArtistListState();
  @override
  List<Object> get props => [];
}

class ArtistListInitial extends ArtistListState {}

class ArtistListLoading extends ArtistListState {}

class ArtistListLoaded extends ArtistListState {
  final List<ArtistModel> artists;
  const ArtistListLoaded({required this.artists});
  @override
  List<Object> get props => [artists];
}

class ArtistListError extends ArtistListState {
  final String message;
  const ArtistListError({required this.message});
  @override
  List<Object> get props => [message];
}

class SongsByArtistLoading extends ArtistListState {}

class SongsByArtistLoaded extends ArtistListState {
  final List<AudioFile> songs;
  const SongsByArtistLoaded({required this.songs});
  @override
  List<Object> get props => [songs];
}

class SongsByArtistError extends ArtistListState {
  final String message;
  const SongsByArtistError({required this.message});
  @override
  List<Object> get props => [message];
}
