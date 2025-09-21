part of 'audio_player_bloc.dart';

abstract class AudioPlayerState extends Equatable {
  final AudioFile? current;
  final PlaybackMode playbackMode;
  final double speed;
  final PlaySource playSource;
  const AudioPlayerState({
    this.playSource = PlaySource.audioList,
    this.current,
    this.playbackMode = PlaybackMode.repeatAll,
    this.speed = 1.0,
  });

  bool get isPlaying => this is AudioPlayerPlaying;

  @override
  List<Object?> get props => [current ?? '', playbackMode, speed, playSource];
}

class AudioPlayerInitial extends AudioPlayerState {
  const AudioPlayerInitial() : super(current: null);
}

class AudioPlayerPlaying extends AudioPlayerState {
  const AudioPlayerPlaying({
    AudioFile? current,
    required PlaybackMode playbackMode,
    required PlaySource playSource,
    double speed = 1.0,
  }) : super(
         current: current,
         playbackMode: playbackMode,
         speed: speed,
         playSource: playSource,
       );
}

class AudioPlayerPaused extends AudioPlayerState {
  const AudioPlayerPaused({
    AudioFile? current,
    required PlaybackMode playbackMode,
    required PlaySource playSource,
    double speed = 1.0,
  }) : super(
         current: current,
         playbackMode: playbackMode,
         speed: speed,
         playSource: playSource,
       );
}
