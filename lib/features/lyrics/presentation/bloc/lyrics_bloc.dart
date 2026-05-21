import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/fetch_lyrics.dart';
import 'lyrics_event.dart';
import 'lyrics_state.dart';

/// BLoC for managing lyrics
class LyricsBloc extends Bloc<LyricsEvent, LyricsState> {
  final FetchLyrics fetchLyricsUsecase;

  LyricsBloc({required this.fetchLyricsUsecase}) : super(const LyricsInitial()) {
    on<FetchLyricsEvent>(_onFetchLyrics);
    on<UpdatePositionEvent>(_onUpdatePosition);
    on<ClearLyricsEvent>(_onClearLyrics);
  }

  /// Handle FetchLyricsEvent
  Future<void> _onFetchLyrics(
    FetchLyricsEvent event,
    Emitter<LyricsState> emit,
  ) async {
    emit(const LyricsLoading());

    final result = await fetchLyricsUsecase(
      title: event.title,
      artist: event.artist,
      duration: event.duration,
    );

    result.fold(
      (failure) => emit(LyricsError(failure.message)),
      (lyrics) {
        if (lyrics != null) {
          emit(LyricsLoaded(lyrics: lyrics));
        } else {
          emit(
            const LyricsNotFound(
              message: 'No lyrics found for this song',
            ),
          );
        }
      },
    );
  }

  /// Handle UpdatePositionEvent to update current lyric index
  Future<void> _onUpdatePosition(
    UpdatePositionEvent event,
    Emitter<LyricsState> emit,
  ) async {
    if (state is LyricsLoaded) {
      final loadedState = state as LyricsLoaded;
      if (loadedState.lyrics.isSynced) {
        final newIndex = loadedState.lyrics.getCurrentLyricIndex(event.position);
        if (newIndex != loadedState.currentLyricIndex) {
          emit(loadedState.copyWith(currentLyricIndex: newIndex));
        }
      }
    }
  }

  /// Handle ClearLyricsEvent
  Future<void> _onClearLyrics(
    ClearLyricsEvent event,
    Emitter<LyricsState> emit,
  ) async {
    emit(const LyricsInitial());
  }
}
