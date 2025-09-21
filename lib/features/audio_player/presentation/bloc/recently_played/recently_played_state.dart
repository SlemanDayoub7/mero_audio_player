import 'package:equatable/equatable.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/recently_played_event.dart';

abstract class RecentlyPlayedState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RecentlyPlayedInitial extends RecentlyPlayedState {}

class RecentlyPlayedLoading extends RecentlyPlayedState {}

class RecentlyPlayedLoaded extends RecentlyPlayedState {
  final RecentlyPlayedAudio? audio;
  final List<AudioFile> audios;
  RecentlyPlayedLoaded({this.audio, required this.audios});

  @override
  List<Object?> get props => [audio];
}

class RecentlyPlayedError extends RecentlyPlayedState {
  final String message;
  RecentlyPlayedError(this.message);

  @override
  List<Object?> get props => [message];
}
