import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_service/audio_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/services/audio_handler.dart';

part 'audio_player_state.dart';

class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  final AudioPlayerHandler _handler;

  StreamSubscription<Duration>? _posSub;
  StreamSubscription<PlaybackState>? _playbackSub;
  StreamSubscription<MediaItem?>? _mediaSub;

  AudioFile? _currentAudio;
  String _currentIndex = '';
  Duration _lastPos = Duration.zero;
  Duration _lastDur = Duration.zero;

  // ✅ معرّف playlist لمنع إعادة التحميل
  String _currentPlaylistId = '';
  String get currentPlaylistId => _currentPlaylistId;
  AudioFile? get currentAudio => _currentAudio;
  AudioPlayerCubit(this._handler) : super(const AudioPlayerInitial()) {
    _posSub = _handler.player.positionStream.listen((pos) {
      _lastPos = pos;
      _emitState();
    });

    _playbackSub = _handler.playbackState.listen((ps) {
      if (ps.processingState == AudioProcessingState.loading ||
          ps.processingState == AudioProcessingState.buffering) {
        emit(const AudioPlayerLoading());
        return;
      }
      if (ps.processingState == AudioProcessingState.completed) {
        emit(const AudioPlayerCompleted());
        return;
      }
      _emitState();
    });

    _mediaSub = _handler.mediaItem.listen((item) {
      if (item != null) {
        _currentAudio = AudioFile(
          id: int.tryParse(item.id) ?? 0,
          title: item.title,
          artist: item.artist,
          album: item.album,
          uri: item.extras?['uri'],
          duration: item.duration?.inMilliseconds,
        );
        _lastDur = item.duration ?? Duration.zero;
        _emitState();
      }
    });
  }

  Future<void> loadPlaylist(
    List<AudioFile> audios, {
    int startIndex = 0,
    bool autoRun = true,
  }) async {
    final newPlaylistId = audios.map((a) => a.id).join('-');

    // ✅ إذا نفس القائمة، لا تعيد التحميل
    if (newPlaylistId == _currentPlaylistId) {
      _handler.player.seek(Duration.zero, index: startIndex);
      if (autoRun) play();
      return;
    }

    _currentPlaylistId = newPlaylistId;
    _currentIndex = startIndex.toString() + audios[startIndex].id.toString();

    await _handler.setPlaylist(
      audios,
      startIndex: startIndex,
      autoRun: autoRun,
    );
  }

  // ✅ تشغيل أغنية معينة فقط بدون إعادة تحميل playlist
  void playIndex(int index) {
    _handler.player.seek(Duration.zero, index: index);
    play();
  }

  bool isCurrentPlaying(int index) {
    // تحقق من أن الأغنية الحالية هي نفسها والفيديو يعمل
    return _handler.player.currentIndex == index && _handler.player.playing;
  }

  void play() => _handler.play();
  void pause() => _handler.pause();
  void next() => _handler.skipToNext();
  void previous() => _handler.skipToPrevious();
  void seek(Duration pos) => _handler.seek(pos);

  void _emitState() {
    if (_currentAudio == null) return;
    final isPlaying = _handler.player.playing;
    if (isPlaying) {
      emit(
        AudioPlayerPlaying(_currentAudio!, _currentIndex, _lastPos, _lastDur),
      );
    } else {
      emit(
        AudioPlayerPaused(_currentAudio!, _currentIndex, _lastPos, _lastDur),
      );
    }
  }

  @override
  Future<void> close() {
    _posSub?.cancel();
    _playbackSub?.cancel();
    _mediaSub?.cancel();
    return super.close();
  }
}
