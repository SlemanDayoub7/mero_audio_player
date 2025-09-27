import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/chapter.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/playlist.dart';
import 'package:mero_audio_player/features/audio_player/domain/repositories/playlists_repository.dart';

part 'playlist_event.dart';
part 'playlist_state.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final PlaylistRepository repository;
  List<Playlist> _fullPlayLists = [];
  PlaylistBloc({required this.repository}) : super(PlaylistLoading()) {
    on<LoadPlaylists>((event, emit) async {
      emit(PlaylistLoading());
      try {
        var playlists = await repository.getAllPlaylists();
        _fullPlayLists = playlists;
        if (_fullPlayLists.indexWhere((e) => e.name == '0') == -1) {
          await repository.createPlaylist(
            Playlist(name: '0', audios: [], id: ''),
          );
          playlists = await repository.getAllPlaylists();
        }
        emit(PlaylistLoaded(playlists: playlists));
      } catch (e) {
        emit(PlaylistError(message: e.toString()));
      }
    });

    on<CreatePlaylist>((event, emit) async {
      try {
        await repository.createPlaylist(
          Playlist(name: event.name, audios: [], id: ''),
        );
        add(LoadPlaylists());
      } catch (e) {
        emit(PlaylistError(message: e.toString()));
      }
    });
    on<AddAudiobook>((event, emit) async {
      await repository.createPlaylist(
        Playlist(
          name: event.name,
          audios: [],
          id: '',
          chapters: event.chapters,
          isAudiobook: true,
        ),
      );
      for (var audio in event.audios) {
        await repository.addAudioToPlaylist(event.name, audio);
      }
      add(LoadPlaylists());
    });
    on<SearchPlaylist>((event, emit) {
      if (state is PlaylistLoaded) {
        final query = event.query.toLowerCase();
        final filtered =
            _fullPlayLists.where((playlist) {
              final title = playlist.name.toLowerCase();
              return title.contains(query);
            }).toList();
        emit(PlaylistLoaded(playlists: filtered));
      }
    });
    on<AddAudioToPlaylist>((event, emit) async {
      if (_fullPlayLists.indexWhere((e) => e.name == '0') == -1) {
        await repository.createPlaylist(
          Playlist(name: event.name, audios: [], id: ''),
        );
      }
      await repository.addAudioToPlaylist(event.name, event.audio);
      add(LoadPlaylists());
    });

    on<RemoveAudioFromPlaylist>((event, emit) async {
      await repository.removeAudioFromPlaylist(event.name, event.audio);
      add(LoadPlaylists());
    });

    on<DeletePlaylist>((event, emit) async {
      await repository.deletePlaylist(event.name);
      add(LoadPlaylists());
    });
  }
  bool isFavorite(int id) {
    List<AudioFile> favoriteList =
        _fullPlayLists.firstWhere((e) => e.name == '0').audios;
    return (favoriteList.indexWhere((e) => e.id == id) >= 0);
  }
}
