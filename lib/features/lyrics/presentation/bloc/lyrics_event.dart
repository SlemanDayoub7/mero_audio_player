import 'package:equatable/equatable.dart';

abstract class LyricsEvent extends Equatable {
  const LyricsEvent();

  @override
  List<Object> get props => [];
}

/// Event to fetch lyrics for a song
class FetchLyricsEvent extends LyricsEvent {
  final String title;
  final String artist;
  final Duration duration;

  const FetchLyricsEvent({
    required this.title,
    required this.artist,
    required this.duration,
  });

  @override
  List<Object> get props => [title, artist, duration];
}

/// Event to clear current lyrics
class ClearLyricsEvent extends LyricsEvent {
  const ClearLyricsEvent();
}

/// Event to update current position (for synced lyrics)
class UpdatePositionEvent extends LyricsEvent {
  final Duration position;

  const UpdatePositionEvent(this.position);

  @override
  List<Object> get props => [position];
}
