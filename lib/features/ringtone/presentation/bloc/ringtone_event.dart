abstract class SetRingToneEvent {}

class PlayAudio extends SetRingToneEvent {
  final String url;
  final double start;
  final double end;
  final bool loop;
  PlayAudio(this.url, this.start, this.end, {this.loop = false});
}

class PauseAudio extends SetRingToneEvent {}

class RestartAudio extends SetRingToneEvent {
  final String url;
  final double start;
  final double end;
  final bool loop;
  RestartAudio(this.url, this.start, this.end, {this.loop = false});
}

class UpdatePosition extends SetRingToneEvent {
  final Duration position;
  UpdatePosition(this.position);
}
