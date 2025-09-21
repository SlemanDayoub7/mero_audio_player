// part of 'audio_player_bloc.dart';

// abstract class AudioPlayerEvent extends Equatable {
//   const AudioPlayerEvent();

//   @override
//   List<Object?> get props => [];
// }
// class ToggleShuffle extends AudioPlayerEvent {}

// class ToggleRepeat extends AudioPlayerEvent {}
// class PlayAudio extends AudioPlayerEvent {
//   final AudioFile audio;
//   final List<AudioFile> audios;

//   const PlayAudio({required this.audio, required this.audios});

//   @override
//   List<Object?> get props => [audio, audios];
// }

// class PauseAudio extends AudioPlayerEvent {}

// class ResumeAudio extends AudioPlayerEvent {}

// class StopAudio extends AudioPlayerEvent {}

// class SeekAudio extends AudioPlayerEvent {
//   final Duration position;
//   const SeekAudio(this.position);

//   @override
//   List<Object?> get props => [position];
// }

// class NextAudio extends AudioPlayerEvent {}

// class PreviousAudio extends AudioPlayerEvent {}

// // Internal event for automatic track changes
// class _InternalAudioChanged extends AudioPlayerEvent {
//   final AudioFile audio;
//   _InternalAudioChanged(this.audio);

//   @override
//   List<Object?> get props => [audio];
// }
part of 'audio_player_bloc.dart';

abstract class AudioPlayerEvent extends Equatable {
  const AudioPlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlayAudioRange extends AudioPlayerEvent {
  final AudioFile audio;
  final Duration start;
  final Duration end;

  const PlayAudioRange({
    required this.audio,
    required this.start,
    required this.end,
  });

  @override
  List<Object?> get props => [audio, start, end];
}

class PlayAudio extends AudioPlayerEvent {
  final AudioFile audio;
  final List<AudioFile> audios;
  final bool? runAutomatically;
  const PlayAudio({
    required this.audio,
    this.runAutomatically = true,
    required this.audios,
  });

  @override
  List<Object?> get props => [audio, audios, runAutomatically];
}

class SetPlaybackSpeed extends AudioPlayerEvent {
  final double speed;

  const SetPlaybackSpeed(this.speed);

  @override
  List<Object?> get props => [speed];
}

class ToggleCustomEQ extends AudioPlayerEvent {
  final bool isEnabled;

  const ToggleCustomEQ(this.isEnabled);

  @override
  List<Object?> get props => [isEnabled];
}

class OpenSystemEQ extends AudioPlayerEvent {}

class PauseAudio extends AudioPlayerEvent {}

class ResumeAudio extends AudioPlayerEvent {}

class StopAudio extends AudioPlayerEvent {}

class SeekAudio extends AudioPlayerEvent {
  final Duration position;
  const SeekAudio(this.position);

  @override
  List<Object?> get props => [position];
}

class NextAudio extends AudioPlayerEvent {}

class PreviousAudio extends AudioPlayerEvent {}

class TogglePlaybackMode extends AudioPlayerEvent {
  final PlaybackMode playbackMode;

  const TogglePlaybackMode({required this.playbackMode});

  @override
  List<Object?> get props => [playbackMode];
}

class SetEqualizerBand extends AudioPlayerEvent {
  final int bandIndex;
  final double level; // مستوى الـ gain بالديسبل

  const SetEqualizerBand({required this.bandIndex, required this.level});

  @override
  List<Object?> get props => [bandIndex, level];
}

// Internal event for track changes
class _InternalAudioChanged extends AudioPlayerEvent {
  final AudioFile audio;
  const _InternalAudioChanged(this.audio);

  @override
  List<Object?> get props => [audio];
}

enum PlaybackMode { repeatAll, repeatOne, shuffle }
