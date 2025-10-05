// States
import 'package:equatable/equatable.dart';

abstract class EqualizerState extends Equatable {
  const EqualizerState();

  @override
  List<Object?> get props => [];
}

class EqualizerInitial extends EqualizerState {
  const EqualizerInitial();
}

class EqualizerLoading extends EqualizerState {
  const EqualizerLoading();
}

class EqualizerLoaded extends EqualizerState {
  final bool enabled;
  final List<double> bandLevels;
  final List<int> centerFreqs;
  final double minLevel;
  final double maxLevel;
  final String? selectedPreset;

  const EqualizerLoaded({
    required this.enabled,
    required this.bandLevels,
    required this.centerFreqs,
    required this.minLevel,
    required this.maxLevel,
    this.selectedPreset,
  });

  EqualizerLoaded copyWith({
    bool? enabled,
    List<double>? bandLevels,
    List<int>? centerFreqs,
    double? minLevel,
    double? maxLevel,
    String? selectedPreset,
    bool clearPreset = false,
  }) {
    return EqualizerLoaded(
      enabled: enabled ?? this.enabled,
      bandLevels: bandLevels ?? this.bandLevels,
      centerFreqs: centerFreqs ?? this.centerFreqs,
      minLevel: minLevel ?? this.minLevel,
      maxLevel: maxLevel ?? this.maxLevel,
      selectedPreset:
          clearPreset ? null : (selectedPreset ?? this.selectedPreset),
    );
  }

  @override
  List<Object?> get props => [
    enabled,
    bandLevels,
    centerFreqs,
    minLevel,
    maxLevel,
    selectedPreset,
  ];
}

class EqualizerError extends EqualizerState {
  final String message;
  const EqualizerError(this.message);

  @override
  List<Object?> get props => [message];
}
