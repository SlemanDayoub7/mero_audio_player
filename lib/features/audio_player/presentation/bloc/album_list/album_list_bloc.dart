import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/domain/repositories/audio_repository.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'album_list_event.dart';
part 'album_list_state.dart';

class AlbumListBloc extends Bloc<AlbumListEvent, AlbumListState> {
  final AudioRepository repository;
  List<AlbumModel> _fullAlbumList = [];
  List<AudioFile> _songsByAlbum = [];

  AlbumListBloc({required this.repository}) : super(AlbumListInitial()) {
    on<FetchAlbumList>((event, emit) async {
      emit(AlbumListLoading());
      try {
        _fullAlbumList = await repository.fetchAlbums();
        emit(AlbumListLoaded(Albums: _fullAlbumList));
      } catch (e) {
        emit(AlbumListError(message: e.toString()));
      }
    });

    on<SearchAlbum>((event, emit) {
      if (state is AlbumListLoaded) {
        final query = event.query.toLowerCase();
        final filtered =
            _fullAlbumList.where((album) {
              final name = album.album.toLowerCase();
              return name.contains(query);
            }).toList();
        emit(AlbumListLoaded(Albums: filtered));
      }
    });

    on<FetchSongsByAlbum>((event, emit) async {
      emit(SongsByAlbumLoading());
      try {
        _songsByAlbum = await repository.fetchSongsByAlbum(event.AlbumName);
        emit(SongsByAlbumLoaded(songs: _songsByAlbum));
      } catch (e) {
        emit(SongsByAlbumError(message: e.toString()));
      }
    });
  }

  List<AlbumModel> get fullAlbumList => _fullAlbumList;
  List<AudioFile> get songsByAlbum => _songsByAlbum;
}
