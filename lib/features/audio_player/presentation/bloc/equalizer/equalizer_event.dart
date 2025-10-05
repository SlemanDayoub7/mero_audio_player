import 'package:equatable/equatable.dart';

abstract class EqualizerEvent extends Equatable {
  const EqualizerEvent();

  @override
  List<Object?> get props => [];
}

class LoadEqualizer extends EqualizerEvent {
  const LoadEqualizer();
}

class ToggleEqualizer extends EqualizerEvent {
  final bool enabled;
  const ToggleEqualizer(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateBandLevel extends EqualizerEvent {
  final int bandId;
  final double value;
  const UpdateBandLevel(this.bandId, this.value);

  @override
  List<Object?> get props => [bandId, value];
}

class ApplyPreset extends EqualizerEvent {
  final String presetName;
  const ApplyPreset(this.presetName);

  @override
  List<Object?> get props => [presetName];
}
