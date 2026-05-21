import 'package:equatable/equatable.dart';

import '../../domain/entities/lyrics.dart';

abstract class LyricsState extends Equatable {
  const LyricsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class LyricsInitial extends LyricsState {
  const LyricsInitial();
}

/// Loading lyrics
class LyricsLoading extends LyricsState {
  const LyricsLoading();
}

/// Lyrics loaded successfully
class LyricsLoaded extends LyricsState {
  final Lyrics lyrics;
  final int? currentLyricIndex; // Index of current line for synced lyrics

  const LyricsLoaded({
    required this.lyrics,
    this.currentLyricIndex,
  });

  @override
  List<Object?> get props => [lyrics, currentLyricIndex];

  LyricsLoaded copyWith({
    Lyrics? lyrics,
    int? currentLyricIndex,
  }) {
    return LyricsLoaded(
      lyrics: lyrics ?? this.lyrics,
      currentLyricIndex: currentLyricIndex ?? this.currentLyricIndex,
    );
  }
}

/// No lyrics found
class LyricsNotFound extends LyricsState {
  final String message;

  const LyricsNotFound({this.message = 'Lyrics not found'});

  @override
  List<Object> get props => [message];
}

/// Error loading lyrics
class LyricsError extends LyricsState {
  final String message;

  const LyricsError(this.message);

  @override
  List<Object> get props => [message];
}
