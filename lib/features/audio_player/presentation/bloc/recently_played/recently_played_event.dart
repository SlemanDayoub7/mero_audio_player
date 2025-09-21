import 'package:equatable/equatable.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/recently_played_event.dart';

abstract class RecentlyPlayedEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadRecentlyPlayed extends RecentlyPlayedEvent {}

class SetRecentlyPlayed extends RecentlyPlayedEvent {
  final RecentlyPlayedAudio audio;

  SetRecentlyPlayed(this.audio);

  @override
  List<Object?> get props => [audio];
}

class ClearRecentlyPlayed extends RecentlyPlayedEvent {}
// 1000643182