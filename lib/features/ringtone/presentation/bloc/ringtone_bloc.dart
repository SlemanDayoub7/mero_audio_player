// set_ringtone_bloc.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mero_audio_player/features/ringtone/presentation/bloc/ringtone_event.dart';
import 'package:mero_audio_player/features/ringtone/presentation/bloc/ringtone_state.dart';

import 'dart:async';

class SetRingToneBloc extends Bloc<SetRingToneEvent, SetRingToneState> {
  final AudioPlayer player = AudioPlayer();
  StreamSubscription? _positionSub;

  double startPosition = 0;
  double endPosition = 0;
  bool loop = false;

  SetRingToneBloc() : super(const SetRingToneInitial()) {
    on<PlayAudio>(_onPlayAudio);
    on<PauseAudio>(_onPauseAudio);
    on<RestartAudio>(_onRestartAudio);
    on<UpdatePosition>((event, emit) {
      if (state is SetRingTonePlaying) {
        emit(SetRingTonePlaying(position: event.position));
      } else if (state is SetRingTonePaused) {
        emit(SetRingTonePaused(position: event.position));
      }
    });

    _positionSub = player.onPositionChanged.listen((pos) async {
      add(UpdatePosition(pos));
      if (state is SetRingTonePlaying &&
          endPosition > 0 &&
          pos.inMilliseconds >= (endPosition * 1000).toInt()) {
        await player.pause();
        await player.seek(
          Duration(milliseconds: (startPosition * 1000).toInt()),
        );
        if (loop) {
          await player.resume();
        } else {
          add(PauseAudio());
        }
      }
    });
  }

  Future<void> _onPlayAudio(
    PlayAudio event,
    Emitter<SetRingToneState> emit,
  ) async {
    startPosition = event.start;
    endPosition = event.end;
    loop = event.loop;

    if (player.state == PlayerState.stopped) {
      await player.play(
        DeviceFileSource(event.url), // أو UrlSource لو رابط
        position: Duration(milliseconds: (startPosition * 1000).toInt()),
      );
    } else if (player.state == PlayerState.paused) {
      await player.resume();
    } else {
      // إذا شغال بالفعل فقط اعمل seek للبداية
      await player.seek(Duration(milliseconds: (startPosition * 1000).toInt()));
    }

    emit(SetRingTonePlaying());
  }

  Future<void> _onPauseAudio(
    PauseAudio event,
    Emitter<SetRingToneState> emit,
  ) async {
    await player.pause();
    emit(SetRingTonePaused());
  }

  Future<void> _onRestartAudio(
    RestartAudio event,
    Emitter<SetRingToneState> emit,
  ) async {
    startPosition = event.start;
    endPosition = event.end;
    loop = event.loop;

    await player.stop();
    await player.play(
      DeviceFileSource(event.url),
      position: Duration(milliseconds: (startPosition * 1000).toInt()),
    );

    emit(SetRingTonePlaying());
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();

    player.dispose();
    return super.close();
  }
}
