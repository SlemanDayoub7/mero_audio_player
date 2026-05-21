import '../../domain/entities/lyrics.dart';
import 'lyric_line_model.dart';

/// Data model for Lyrics with JSON serialization
class LyricsModel extends Lyrics {
  const LyricsModel({
    required super.title,
    required super.artist,
    required super.lines,
    required super.duration,
    super.album,
    super.isSynced = false,
    super.source = 'unknown',
  });

  /// Create from JSON
  factory LyricsModel.fromJson(Map<String, dynamic> json) {
    final linesList = (json['lines'] as List?)
            ?.map((line) => LyricLineModel.fromJson(line as Map<String, dynamic>))
            .toList() ??
        [];

    return LyricsModel(
      title: json['title'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      album: json['album'] as String?,
      lines: linesList,
      isSynced: json['isSynced'] as bool? ?? false,
      source: json['source'] as String? ?? 'unknown',
      duration: Duration(milliseconds: json['duration'] as int? ?? 0),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'album': album,
      'lines': lines.map((line) => LyricLineModel.fromEntity(line).toJson()).toList(),
      'isSynced': isSynced,
      'source': source,
      'duration': duration.inMilliseconds,
    };
  }

  /// Create from entity
  factory LyricsModel.fromEntity(Lyrics lyrics) {
    return LyricsModel(
      title: lyrics.title,
      artist: lyrics.artist,
      album: lyrics.album,
      lines: lyrics.lines,
      isSynced: lyrics.isSynced,
      source: lyrics.source,
      duration: lyrics.duration,
    );
  }
}
