import 'package:equatable/equatable.dart';

abstract class RingtoneEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAudio extends RingtoneEvent {
  final String path;
  LoadAudio(this.path);
}

class ChangeSlider extends RingtoneEvent {
  final double start;
  final double end;
  ChangeSlider(this.start, this.end);
}

class PreviewSelection extends RingtoneEvent {}

class SetRingtone extends RingtoneEvent {}
