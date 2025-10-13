import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mero_audio_player/features/music_library/domain/entities/audio_file/audio_file.dart';
import 'package:mero_audio_player/features/music_library/domain/usecases/album_list_usecases/fetch_albums.dart';
import 'package:mero_audio_player/features/music_library/domain/usecases/album_list_usecases/fetch_songs_by_album.dart';
import 'package:mero_audio_player/features/music_library/domain/usecases/album_list_usecases/search_albums.dart';

import 'package:on_audio_query/on_audio_query.dart';

part 'album_list_event.dart';
part 'album_list_state.dart';

class AlbumListBloc extends Bloc<AlbumListEvent, AlbumListState> {
  final FetchAlbums fetchAlbums;
  final FetchSongsByAlbum fetchSongsByAlbum;
  final SearchAlbums searchAlbums;

  List<AlbumModel> _fullAlbumList = [];
  List<AudioFile> _songsByAlbum = [];

  AlbumListBloc({
    required this.fetchAlbums,
    required this.fetchSongsByAlbum,
    required this.searchAlbums,
  }) : super(AlbumListInitial()) {
    on<FetchAlbumList>((event, emit) async {
      emit(AlbumListLoading());
      try {
        _fullAlbumList = await fetchAlbums();
        emit(AlbumListLoaded(Albums: _fullAlbumList));
      } catch (e) {
        emit(AlbumListError(message: e.toString()));
      }
    });

    on<SearchAlbum>((event, emit) {
      if (state is AlbumListLoaded) {
        final filtered = searchAlbums(_fullAlbumList, event.query);
        emit(AlbumListLoaded(Albums: filtered));
      }
    });

    on<FetchSongsByAlbumEvent>((event, emit) async {
      emit(SongsByAlbumLoading());
      try {
        _songsByAlbum = await fetchSongsByAlbum(event.albumName);
        emit(SongsByAlbumLoaded(songs: _songsByAlbum));
      } catch (e) {
        emit(SongsByAlbumError(message: e.toString()));
      }
    });
  }

  List<AlbumModel> get fullAlbumList => _fullAlbumList;
  List<AudioFile> get songsByAlbum => _songsByAlbum;
}
