import '../../../domain/entities/audio_file.dart';

abstract class AudioState {}

class AudioInitial extends AudioState {}

class AudioLoading extends AudioState {}

class AudioLoaded extends AudioState {
  final List<AudioFile> audios;
  AudioLoaded(this.audios);
}

class AudioLoadedForPlay extends AudioState {}

class AudioError extends AudioState {
  final String message;
  AudioError(this.message);
}

class AudioPlaying extends AudioState {}

class AudioPaused extends AudioState {}

class AudioCompleted extends AudioState {}

class AudioPositionChanged extends AudioState {
  final Duration position;
  AudioPositionChanged(this.position);
}

class AudioDurationChanged extends AudioState {
  final Duration duration;
  AudioDurationChanged(this.duration);
}

class AudioTrackChanged extends AudioState {
  final AudioFile currentAudio;
  final int index;
  AudioTrackChanged(this.currentAudio, this.index);
}
