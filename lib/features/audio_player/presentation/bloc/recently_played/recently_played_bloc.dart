import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/recently_played/recently_played_event.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/recently_played/recently_played_state.dart';

class RingtoneBloc extends Bloc<RingtoneEvent, RingtoneState> {
  static const platform = MethodChannel(
    'com.example.mero_audio_player/audio_trimmer',
  );

  final AudioPlayer _player = AudioPlayer();
  Timer? _stopTimer;
  String _audioPath = '';

  RingtoneBloc() : super(const RingtoneState()) {
    on<LoadAudio>(_loadAudio);
    on<ChangeSlider>(_changeSlider);
    on<PreviewSelection>(_preview);
    on<SetRingtone>(_setRingtone);
  }

  Future<void> _loadAudio(LoadAudio event, Emitter<RingtoneState> emit) async {
    _audioPath = event.path;
    emit(state.copyWith(loading: true));

    await _player.setSource(DeviceFileSource(_audioPath));

    // Listen to duration once
    _player.onDurationChanged.listen((d) {
      if (d.inMilliseconds > 0) {
        final dur = d.inMilliseconds / 1000;
        emit(
          state.copyWith(
            loading: false,
            duration: dur,
            start: 0,
            end: dur > 30 ? 30 : dur,
          ),
        );
      }
    });

    // trigger the duration event
    await _player.resume();
    Future.delayed(const Duration(milliseconds: 300), () => _player.pause());
  }

  void _changeSlider(ChangeSlider event, Emitter<RingtoneState> emit) {
    double start = event.start;
    double end = event.end;
    if (end - start > 30) end = start + 30;
    emit(state.copyWith(start: start, end: end));
  }

  Future<void> _preview(
    PreviewSelection event,
    Emitter<RingtoneState> emit,
  ) async {
    _stopTimer?.cancel();
    await _player.stop();
    await _player.setSource(DeviceFileSource(_audioPath));
    await _player.seek(Duration(seconds: state.start.toInt()));
    await _player.resume();

    _stopTimer = Timer(
      Duration(milliseconds: ((state.end - state.start) * 1000).toInt()),
      () => _player.stop(),
    );
  }

  Future<void> _setRingtone(
    SetRingtone event,
    Emitter<RingtoneState> emit,
  ) async {
    emit(state.copyWith(trimming: true));
    try {
      final trimmedPath = await platform.invokeMethod('trimAudio', {
        'inputPath': _audioPath,
        'startMs': (state.start * 1000).round(),
        'endMs': (state.end * 1000).round(),
      });

      if (trimmedPath != null) {
        // e.g., RingtoneSet.setRingtoneFromFile(File(trimmedPath));
        final tmp = File(trimmedPath);
        if (await tmp.exists()) await tmp.delete();
      }
    } finally {
      emit(state.copyWith(trimming: false));
    }
  }

  @override
  Future<void> close() {
    _player.dispose();
    _stopTimer?.cancel();
    return super.close();
  }
}
