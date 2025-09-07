import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../../domain/entities/playlist.dart';

part 'playlist_state.dart';

class PlaylistCubit extends Cubit<PlaylistState> {
  final Box<Playlist> _box;

  PlaylistCubit(this._box) : super(PlaylistInitial()) {
    loadPlaylists();
  }

  void loadPlaylists() {
    final playlists = _box.values.toList();
    emit(PlaylistsLoaded(playlists));
  }

  void addPlaylist(Playlist playlist) async {
    await _box.add(playlist);
    loadPlaylists();
  }

  void updatePlaylist(int index, Playlist playlist) async {
    await _box.putAt(index, playlist);
    loadPlaylists();
  }

  void deletePlaylist(int index) async {
    await _box.deleteAt(index);
    loadPlaylists();
  }
}
