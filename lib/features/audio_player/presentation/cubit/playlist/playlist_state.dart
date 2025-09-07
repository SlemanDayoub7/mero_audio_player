part of 'playlist_cubit.dart';

abstract class PlaylistState {
  const PlaylistState();
}

class PlaylistInitial extends PlaylistState {
  const PlaylistInitial();
}

class PlaylistsLoaded extends PlaylistState {
  final List<Playlist> playlists;
  const PlaylistsLoaded(this.playlists);
}
