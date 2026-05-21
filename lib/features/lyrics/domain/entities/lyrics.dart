import 'package:equatable/equatable.dart';
import 'lyric_line.dart';

/// Represents complete lyrics for a song
class Lyrics extends Equatable {
  /// Song title
  final String title;

  /// Song artist name
  final String artist;

  /// Album name (optional)
  final String? album;

  /// List of lyric lines
  final List<LyricLine> lines;

  /// Indicates if lyrics are synced (have timestamps)
  final bool isSynced;

  /// Source of the lyrics (e.g., 'genius', 'lyrics.com', 'local')
  final String source;

  /// Duration of the song in milliseconds
  final Duration duration;

  const Lyrics({
    required this.title,
    required this.artist,
    required this.lines,
    required this.duration,
    this.album,
    this.isSynced = false,
    this.source = 'unknown',
  });

  @override
  List<Object?> get props => [title, artist, album, lines, isSynced, source, duration];

  /// Create a copy with modifications
  Lyrics copyWith({
    String? title,
    String? artist,
    String? album,
    List<LyricLine>? lines,
    bool? isSynced,
    String? source,
    Duration? duration,
  }) {
    return Lyrics(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      lines: lines ?? this.lines,
      isSynced: isSynced ?? this.isSynced,
      source: source ?? this.source,
      duration: duration ?? this.duration,
    );
  }

  /// Get the current lyric line based on timestamp
  int? getCurrentLyricIndex(Duration currentPosition) {
    if (!isSynced) return null;

    for (int i = lines.length - 1; i >= 0; i--) {
      if (lines[i].timestamp != null && lines[i].timestamp! <= currentPosition) {
        return i;
      }
    }
    return null;
  }
}
