import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../domain/repositories/audio_repository.dart';
import '../../../domain/entities/audio_file/audio_file.dart';

part 'artist_list_event.dart';
part 'artist_list_state.dart';

class ArtistListBloc extends Bloc<ArtistListEvent, ArtistListState> {
  final AudioRepository repository;
  List<ArtistModel> _fullArtistList = [];
  List<AudioFile> _songsByArtist = [];

  ArtistListBloc({required this.repository}) : super(ArtistListInitial()) {
    on<FetchArtistList>((event, emit) async {
      emit(ArtistListLoading());
      try {
        _fullArtistList = await repository.fetchArtists();
        emit(ArtistListLoaded(artists: _fullArtistList));
      } catch (e) {
        emit(ArtistListError(message: e.toString()));
      }
    });

    on<SearchArtist>((event, emit) {
      if (state is ArtistListLoaded) {
        final query = event.query.toLowerCase();
        final filtered =
            _fullArtistList.where((artist) {
              final name = artist.artist.toLowerCase();
              return name.contains(query);
            }).toList();
        emit(ArtistListLoaded(artists: filtered));
      }
    });

    on<FetchSongsByArtist>((event, emit) async {
      emit(SongsByArtistLoading());
      try {
        _songsByArtist = await repository.fetchSongsByArtist(event.artistName);
        emit(SongsByArtistLoaded(songs: _songsByArtist));
      } catch (e) {
        emit(SongsByArtistError(message: e.toString()));
      }
    });
  }

  List<ArtistModel> get fullArtistList => _fullArtistList;
  List<AudioFile> get songsByArtist => _songsByArtist;
}
