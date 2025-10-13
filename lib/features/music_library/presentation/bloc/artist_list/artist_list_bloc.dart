import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mero_audio_player/features/music_library/domain/usecases/artist_list_usecases/fetch_artists.dart';
import 'package:mero_audio_player/features/music_library/domain/usecases/artist_list_usecases/fetch_songs_by_artist.dart';
import 'package:mero_audio_player/features/music_library/domain/usecases/artist_list_usecases/search_artists.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../domain/entities/audio_file/audio_file.dart';

part 'artist_list_event.dart';
part 'artist_list_state.dart';

class ArtistListBloc extends Bloc<ArtistListEvent, ArtistListState> {
  final FetchArtists fetchArtists;
  final FetchSongsByArtist fetchSongsByArtist;
  final SearchArtists searchArtists;

  List<ArtistModel> _fullArtistList = [];
  List<AudioFile> _songsByArtist = [];

  ArtistListBloc({
    required this.fetchArtists,
    required this.fetchSongsByArtist,
    required this.searchArtists,
  }) : super(ArtistListInitial()) {
    on<FetchArtistList>((event, emit) async {
      emit(ArtistListLoading());
      try {
        _fullArtistList = await fetchArtists();
        emit(ArtistListLoaded(artists: _fullArtistList));
      } catch (e) {
        emit(ArtistListError(message: e.toString()));
      }
    });

    on<SearchArtist>((event, emit) {
      if (state is ArtistListLoaded) {
        final filtered = searchArtists(_fullArtistList, event.query);
        emit(ArtistListLoaded(artists: filtered));
      }
    });

    on<FetchSongsByArtistEvent>((event, emit) async {
      emit(SongsByArtistLoading());
      try {
        _songsByArtist = await fetchSongsByArtist(event.artistName);
        emit(SongsByArtistLoaded(songs: _songsByArtist));
      } catch (e) {
        emit(SongsByArtistError(message: e.toString()));
      }
    });
  }

  List<ArtistModel> get fullArtistList => _fullArtistList;
  List<AudioFile> get songsByArtist => _songsByArtist;
}
