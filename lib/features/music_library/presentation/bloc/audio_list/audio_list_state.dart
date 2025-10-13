part of 'audio_list_bloc.dart';

abstract class AudioListState extends Equatable {
  const AudioListState();

  @override
  List<Object?> get props => [];
}

class AudioListInitial extends AudioListState {}

class AudioListLoading extends AudioListState {}

class AudioListLoaded extends AudioListState {
  final List<AudioFile> audios;

  const AudioListLoaded({required this.audios});

  @override
  List<Object?> get props => [audios];
}

class AudioListError extends AudioListState {
  final String message;

  const AudioListError({required this.message});

  @override
  List<Object?> get props => [message];
}
