import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mero_audio_player/core/services/media_store_service.dart';
import 'package:mero_audio_player/features/music_library/domain/usecases/audio_list_usecases/get_audio_files.dart';
import 'package:mero_audio_player/features/music_library/domain/usecases/audio_list_usecases/search_audio_files.dart';
import 'package:mero_audio_player/features/music_library/domain/usecases/audio_list_usecases/sort_audio_files.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../domain/entities/audio_file/audio_file.dart';
import '../../../domain/repositories/audio_repository.dart';

part 'audio_list_event.dart';
part 'audio_list_state.dart';

class AudioListBloc extends Bloc<AudioListEvent, AudioListState> {
  final GetAudioFiles getAudioFiles;
  final SortAudioFiles sortAudioFiles;
  final SearchAudioFiles searchAudioFiles;
  final AudioRepository repository;
  List<AudioFile> _fullList = [];

  AudioListBloc({
    required this.getAudioFiles,
    required this.sortAudioFiles,
    required this.searchAudioFiles,
    required this.repository,
  }) : super(AudioListInitial()) {
    on<FetchAudioList>((event, emit) async {
      emit(AudioListLoading());
      try {
        _fullList = await getAudioFiles.call();
        emit(AudioListLoaded(audios: _fullList));
      } catch (e) {
        emit(AudioListError(message: e.toString()));
      }
    });
    on<LoadAudioList>((event, emit) async {
      emit(AudioListLoading());
      try {
        _fullList = event.audios;
        emit(AudioListLoaded(audios: _fullList));
      } catch (e) {
        emit(AudioListError(message: e.toString()));
      }
    });

    on<SortAudioList>((event, emit) async {
      if (state is AudioListLoaded) {
        List<AudioFile> sortedList = sortAudioFiles.call(
          audios: _fullList,
          sortType: event.sortType,
          orderType: event.orderType,
        );

        // Emit updated state with sorted list and current sort type
        emit(AudioListLoaded(audios: sortedList));
      }
    });

    on<SearchAudio>((event, emit) {
      if (state is AudioListLoaded) {
        final query = event.query.toLowerCase();

        final filtered = searchAudioFiles.call(audios: _fullList, query: query);

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
