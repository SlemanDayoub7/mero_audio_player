abstract class SetRingToneState {
  final Duration position;
  const SetRingToneState({this.position = Duration.zero});
}

class SetRingToneInitial extends SetRingToneState {
  const SetRingToneInitial() : super();
}

class SetRingTonePlaying extends SetRingToneState {
  const SetRingTonePlaying({Duration position = Duration.zero})
    : super(position: position);
}

class SetRingTonePaused extends SetRingToneState {
  const SetRingTonePaused({Duration position = Duration.zero})
    : super(position: position);
}
