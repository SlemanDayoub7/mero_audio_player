part of 'playlist_bloc.dart';

abstract class PlaylistEvent extends Equatable {
  const PlaylistEvent();

  @override
  List<Object?> get props => [];
}

class LoadPlaylists extends PlaylistEvent {}

class CreatePlaylist extends PlaylistEvent {
  final String name;
  const CreatePlaylist(this.name);
  @override
  List<Object?> get props => [name];
}

class SearchPlaylist extends PlaylistEvent {
  final String query;
  const SearchPlaylist(this.query);

  @override
  List<Object?> get props => [query];
}

class AddAudiobook extends PlaylistEvent {
  final String name;
  final AudioFile file;
  final List<AudioFile> audios;
  final List<Chapter> chapters;

  AddAudiobook({
    required this.audios,
    required this.name,
    required this.file,
    required this.chapters,
  });
}

class AddAudioToPlaylist extends PlaylistEvent {
  final String name;
  final AudioFile audio;
  const AddAudioToPlaylist(this.name, this.audio);
  @override
  List<Object?> get props => [name, audio];
}

class RemoveAudioFromPlaylist extends PlaylistEvent {
  final String name;
  final AudioFile audio;
  const RemoveAudioFromPlaylist(this.name, this.audio);
  @override
  List<Object?> get props => [name, audio];
}

class DeletePlaylist extends PlaylistEvent {
  final String name;
  const DeletePlaylist(this.name);
  @override
  List<Object?> get props => [name];
}
