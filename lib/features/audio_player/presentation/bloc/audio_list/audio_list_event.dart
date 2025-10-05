part of 'audio_list_bloc.dart';

abstract class AudioListEvent extends Equatable {
  const AudioListEvent();

  @override
  List<Object?> get props => [];
}

class FetchAudioList extends AudioListEvent {}

class LoadAudioList extends AudioListEvent {
  final List<AudioFile> audios;

  const LoadAudioList(this.audios);

  @override
  List<Object?> get props => [audios];
}

class SearchAudio extends AudioListEvent {
  final String query;
  const SearchAudio(this.query);

  @override
  List<Object?> get props => [query];
}

class SortAudioList extends AudioListEvent {
  final SongSortType sortType;
  final OrderType orderType;
  const SortAudioList(this.sortType, this.orderType);
}

class DeleteAudioFromDevice extends AudioListEvent {
  final AudioFile audio;

  const DeleteAudioFromDevice(this.audio);

  @override
  List<Object?> get props => [audio];
}
