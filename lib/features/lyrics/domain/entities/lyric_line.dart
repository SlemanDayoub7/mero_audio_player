import 'package:equatable/equatable.dart';

/// Represents a single line of lyrics with optional timestamp for synced lyrics
class LyricLine extends Equatable {
  /// The timestamp in milliseconds (null for non-synced lyrics)
  final Duration? timestamp;

  /// The text content of the lyric line
  final String text;

  const LyricLine({
    required this.text,
    this.timestamp,
  });

  @override
  List<Object?> get props => [timestamp, text];

  /// Create a copy with modifications
  LyricLine copyWith({
    Duration? timestamp,
    String? text,
  }) {
    return LyricLine(
      timestamp: timestamp ?? this.timestamp,
      text: text ?? this.text,
    );
  }
}
