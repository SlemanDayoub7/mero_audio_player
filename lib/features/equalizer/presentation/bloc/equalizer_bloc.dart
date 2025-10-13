import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equalizer_flutter/equalizer_flutter.dart';
import 'package:mero_audio_player/features/equalizer/presentation/bloc/equalizer_event.dart';
import 'package:mero_audio_player/features/equalizer/presentation/bloc/equalizer_state.dart';

class EqualizerBloc extends Bloc<EqualizerEvent, EqualizerState> {
  EqualizerBloc() : super(const EqualizerInitial()) {
    on<LoadEqualizer>(_onInitialize);
    on<ToggleEqualizer>(_onToggle);
    on<UpdateBandLevel>(_onUpdateBandLevel);
    on<ApplyPreset>(_onApplyPreset);
  }

  Future<void> _onInitialize(
    LoadEqualizer event,
    Emitter<EqualizerState> emit,
  ) async {
    try {
      emit(const EqualizerLoading());

      EqualizerFlutter.init(0);

      final bandLevelRange = await EqualizerFlutter.getBandLevelRange();
      final centerFreqs = await EqualizerFlutter.getCenterBandFreqs();

      List<double> levels = [];
      for (int i = 0; i < centerFreqs.length; i++) {
        final level = await EqualizerFlutter.getBandLevel(i);
        levels.add(level.toDouble());
      }

      emit(
        EqualizerLoaded(
          enabled: false,
          bandLevels: levels,
          centerFreqs: centerFreqs,
          minLevel: bandLevelRange[0].toDouble(),
          maxLevel: bandLevelRange[1].toDouble(),
        ),
      );
    } catch (e) {
      emit(EqualizerError('Failed to initialize equalizer: $e'));
    }
  }

  Future<void> _onToggle(
    ToggleEqualizer event,
    Emitter<EqualizerState> emit,
  ) async {
    if (state is EqualizerLoaded) {
      final currentState = state as EqualizerLoaded;
      EqualizerFlutter.setEnabled(event.enabled);
      emit(currentState.copyWith(enabled: event.enabled));
    }
  }

  Future<void> _onUpdateBandLevel(
    UpdateBandLevel event,
    Emitter<EqualizerState> emit,
  ) async {
    if (state is EqualizerLoaded) {
      final currentState = state as EqualizerLoaded;
      final updatedLevels = List<double>.from(currentState.bandLevels);
      updatedLevels[event.bandId] = event.value;

      await EqualizerFlutter.setBandLevel(event.bandId, event.value.toInt());

      emit(currentState.copyWith(bandLevels: updatedLevels, clearPreset: true));
    }
  }

  Future<void> _onApplyPreset(
    ApplyPreset event,
    Emitter<EqualizerState> emit,
  ) async {
    if (state is EqualizerLoaded) {
      final currentState = state as EqualizerLoaded;

      // Define preset values
      final Map<String, List<double>> presetValues = {
        'Flat': List.filled(5, 0.0),
        'Bass Booster': [8.0, 6.0, 2.0, 0.0, 0.0],
        'Vocal Booster': [0.0, 3.0, 6.0, 6.0, 3.0],
        'Pop': [2.0, 4.0, 3.0, 0.0, 2.0],
        'Rock': [4.0, 3.0, 0.0, 2.0, 4.0],
        'Hip Hop': [6.0, 4.0, 0.0, 2.0, 4.0],
        'Heavy Metal': [5.0, 3.0, 0.0, 3.0, 5.0],
        'Electronic': [4.0, 3.0, 0.0, 3.0, 5.0],
        'R&B': [5.0, 3.0, 0.0, 2.0, 3.0],
        'Folk': [2.0, 0.0, 0.0, 2.0, 3.0],
        'Jazz': [3.0, 2.0, 0.0, 2.0, 3.0],
        'Dance': [5.0, 3.0, 0.0, 2.0, 4.0],
        'Classical': [3.0, 2.0, 0.0, 2.0, 4.0],
        'Latin': [4.0, 2.0, 0.0, 3.0, 4.0],
      };

      final values =
          presetValues[event.presetName] ??
          List.filled(currentState.bandLevels.length, 0.0);

      // Apply to equalizer
      for (
        int i = 0;
        i < values.length && i < currentState.bandLevels.length;
        i++
      ) {
        await EqualizerFlutter.setBandLevel(i, values[i].toInt());
      }

      emit(
        currentState.copyWith(
          bandLevels: List.from(values),
          selectedPreset: event.presetName,
        ),
      );
    }
  }
}
