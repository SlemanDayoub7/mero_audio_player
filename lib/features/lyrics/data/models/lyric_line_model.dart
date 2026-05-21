import '../../domain/entities/lyric_line.dart';

/// Data model for LyricLine with JSON serialization
class LyricLineModel extends LyricLine {
  const LyricLineModel({
    required super.text,
    super.timestamp,
  });

  /// Create from JSON
  factory LyricLineModel.fromJson(Map<String, dynamic> json) {
    return LyricLineModel(
      text: json['text'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? Duration(milliseconds: json['timestamp'] as int)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'timestamp': timestamp?.inMilliseconds,
    };
  }

  /// Create from LyricLine entity
  factory LyricLineModel.fromEntity(LyricLine lyricLine) {
    return LyricLineModel(
      text: lyricLine.text,
      timestamp: lyricLine.timestamp,
    );
  }
}
