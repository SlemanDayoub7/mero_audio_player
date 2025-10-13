part of 'playlist_bloc.dart';

abstract class PlaylistState extends Equatable {
  const PlaylistState();

  @override
  List<Object?> get props => [];
}

class PlaylistLoading extends PlaylistState {}

class PlaylistLoaded extends PlaylistState {
  final List<Playlist> playlists;
  const PlaylistLoaded({required this.playlists});
  @override
  List<Object?> get props => [playlists];
}

class PlaylistError extends PlaylistState {
  final String message;
  const PlaylistError({required this.message});
  @override
  List<Object?> get props => [message];
}
