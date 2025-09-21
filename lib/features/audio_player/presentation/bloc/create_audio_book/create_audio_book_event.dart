import 'package:equatable/equatable.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/chapter.dart';

abstract class CreateAudiobookEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class NameChanged extends CreateAudiobookEvent {
  final String name;
  NameChanged(this.name);
  @override
  List<Object?> get props => [name];
}

class ChapterNameChanged extends CreateAudiobookEvent {
  final String name;
  ChapterNameChanged(this.name);
  @override
  List<Object?> get props => [name];
}

class RangeChanged extends CreateAudiobookEvent {
  final double startMs;
  final double endMs;
  RangeChanged(this.startMs, this.endMs);
  @override
  List<Object?> get props => [startMs, endMs];
}

class AddChapter extends CreateAudiobookEvent {}

class UndoChapter extends CreateAudiobookEvent {} // جديد: التراجع عن آخر فصل

class PlayRange extends CreateAudiobookEvent {}

class PlayChapter extends CreateAudiobookEvent {
  final Chapter chapter;
  PlayChapter(this.chapter);
  @override
  List<Object?> get props => [chapter];
}

class StopAudio extends CreateAudiobookEvent {}

class SaveAudiobook extends CreateAudiobookEvent {}

class UpdateProgress extends CreateAudiobookEvent {
  final Duration position;
  UpdateProgress(this.position);
  @override
  List<Object?> get props => [position];
}
