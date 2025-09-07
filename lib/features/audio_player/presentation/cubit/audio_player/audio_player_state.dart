part of 'audio_player_cubit.dart';

abstract class AudioPlayerState {
  const AudioPlayerState();
}

class AudioPlayerInitial extends AudioPlayerState {
  const AudioPlayerInitial();
}

class AudioPlayerLoading extends AudioPlayerState {
  const AudioPlayerLoading();
}

class AudioPlayerPlaying extends AudioPlayerState {
  final AudioFile audio;
  final String index;
  final Duration position;
  final Duration duration;
  final int version; // إضافة رقم النسخة

  const AudioPlayerPlaying(
    this.audio,
    this.index,
    this.position,
    this.duration, {
    this.version = 0,
  });

  AudioPlayerPlaying copyWith({
    AudioFile? audio,
    String? index,
    Duration? position,
    Duration? duration,
    int? version,
  }) {
    return AudioPlayerPlaying(
      audio ?? this.audio,
      index ?? this.index,
      position ?? this.position,
      duration ?? this.duration,
      version: version ?? this.version,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AudioPlayerPlaying &&
        other.audio == audio &&
        other.index == index &&
        other.position == position &&
        other.duration == duration &&
        other.version == version;
  }

  @override
  int get hashCode {
    return audio.hashCode ^
        index.hashCode ^
        position.hashCode ^
        duration.hashCode ^
        version.hashCode;
  }
}

class AudioPlayerPaused extends AudioPlayerState {
  final AudioFile audio;
  final String index;
  final Duration position;
  final Duration duration;
  final int version; // إضافة رقم النسخة

  const AudioPlayerPaused(
    this.audio,
    this.index,
    this.position,
    this.duration, {
    this.version = 0,
  });

  AudioPlayerPaused copyWith({
    AudioFile? audio,
    String? index,
    Duration? position,
    Duration? duration,
    int? version,
  }) {
    return AudioPlayerPaused(
      audio ?? this.audio,
      index ?? this.index,
      position ?? this.position,
      duration ?? this.duration,
      version: version ?? this.version,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AudioPlayerPaused &&
        other.audio == audio &&
        other.index == index &&
        other.position == position &&
        other.duration == duration &&
        other.version == version;
  }

  @override
  int get hashCode {
    return audio.hashCode ^
        index.hashCode ^
        position.hashCode ^
        duration.hashCode ^
        version.hashCode;
  }
}

class AudioPlayerCompleted extends AudioPlayerState {
  const AudioPlayerCompleted();
}
