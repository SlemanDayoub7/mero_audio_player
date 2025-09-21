import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mero_audio_player/features/audio_player/services/media_store_service.dart';
import 'package:mero_audio_player/injection.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../domain/entities/audio_file.dart';
import '../../../domain/repositories/audio_repository.dart';

part 'audio_list_event.dart';
part 'audio_list_state.dart';

class AudioListBloc extends Bloc<AudioListEvent, AudioListState> {
  final AudioRepository repository;
  List<AudioFile> _fullList = [];

  AudioListBloc({required this.repository}) : super(AudioListInitial()) {
    on<FetchAudioList>((event, emit) async {
      emit(AudioListLoading());
      try {
        _fullList = await repository.fetchAudioFiles();
        emit(AudioListLoaded(audios: _fullList));
      } catch (e) {
        emit(AudioListError(message: e.toString()));
      }
    });

    on<SortAudioList>((event, emit) async {
      if (state is AudioListLoaded) {
        // Copy existing full list for sorting
        List<AudioFile> sortedList = List.from(_fullList);

        // Sort by selected SongSortType
        switch (event.sortType) {
          case SongSortType.ARTIST:
            sortedList.sort(
              (a, b) => a.artistOrUnknown.toLowerCase().compareTo(
                b.artistOrUnknown.toLowerCase(),
              ),
            );
            break;
          case SongSortType.DATE_ADDED:
            sortedList.sort((a, b) => a.dateAdded!.compareTo(b.dateAdded!));
            break;
          case SongSortType.TITLE:
            sortedList.sort(
              (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
            );
            break;
          case SongSortType.ALBUM:
            sortedList.sort(
              (a, b) => a.albumOrUnknown.toLowerCase().compareTo(
                b.albumOrUnknown.toLowerCase(),
              ),
            );
            break;
          case SongSortType.DURATION:
            sortedList.sort((a, b) => a.duration!.compareTo(b.duration!));
            break;
          case SongSortType.SIZE:
            sortedList.sort((a, b) => a.size!.compareTo(b.size!));
            break;
          case SongSortType.DISPLAY_NAME:
            break;
        }
        if (event.orderType == OrderType.DESC_OR_GREATER) {
          sortedList = sortedList.reversed.toList();
        }
        // Emit updated state with sorted list and current sort type
        emit(AudioListLoaded(audios: sortedList));
      }
    });

    on<SearchAudio>((event, emit) {
      if (state is AudioListLoaded) {
        final query = event.query.toLowerCase();
        final filtered =
            _fullList.where((audio) {
              final title = audio.title.toLowerCase();
              final artist = audio.artistOrUnknown.toLowerCase();
              final album = audio.albumOrUnknown.toLowerCase();
              return title.contains(query) ||
                  artist.contains(query) ||
                  album.contains(query);
            }).toList();
        emit(AudioListLoaded(audios: filtered));
      }
    });

    on<DeleteAudioFromDevice>((event, emit) async {
      if (state is AudioListLoaded) {
        final currentList = List<AudioFile>.from(_fullList);
        // استخدم uri من AudioFile
        final uri = event.audio.uri;
        if (uri == null) {
          emit(AudioListError(message: 'لا يوجد URI للملف'));
          return;
        }

        final deleted = await MediaStoreService.deleteAudio(uri);
        if (deleted) {
          currentList.removeWhere((a) => a.id == event.audio.id);
          _fullList = currentList;
          emit(AudioListLoaded(audios: currentList));
        } else {
          emit(AudioListError(message: 'فشل حذف ${event.audio.title}'));
        }
      }
    });
  }

  // Expose full list for playing from search results
  List<AudioFile> get fullList => _fullList;
}
