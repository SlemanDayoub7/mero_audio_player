import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';

class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final _player = AudioPlayer();
  AudioPlayer get player => _player;
  List<AudioFile> get currentPlaylist =>
      queue.value
          .map(
            (item) => AudioFile(
              id: int.parse(item.id),
              title: item.title,
              artist: item.artist,
              album: item.album,
              uri: item.extras?['uri'],
              duration: item.duration?.inMilliseconds,
            ),
          )
          .toList();
  // Stream for current position
  Stream<Duration> get positionStream => _player.positionStream;

  // Stream for total duration
  Stream<Duration?> get durationStream => _player.durationStream;

  AudioPlayerHandler() {
    // تحديث حالة المشغل باستمرار
    _player.playerStateStream.listen((state) {
      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            state.playing ? MediaControl.pause : MediaControl.play,
            MediaControl.skipToNext,
            MediaControl.stop,
          ],
          playing: state.playing,
          processingState:
              {
                ProcessingState.idle: AudioProcessingState.idle,
                ProcessingState.loading: AudioProcessingState.loading,
                ProcessingState.buffering: AudioProcessingState.buffering,
                ProcessingState.ready: AudioProcessingState.ready,
                ProcessingState.completed: AudioProcessingState.completed,
              }[state.processingState]!,
        ),
      );
    });

    // تتبع الأغنية الحالية
    _player.currentIndexStream.listen((index) {
      if (index != null && index < queue.value.length) {
        mediaItem.add(queue.value[index]);
      }
    });
  }
  Future<void> setPlaylist(
    List<AudioFile> audios, {
    bool autoRun = true,
    int? initIndex,
  }) async {
    final items = <MediaItem>[];
    final sources = <AudioSource>[];

    for (var a in audios) {
      try {
        // Create MediaItem
        final mediaItem = MediaItem(
          id: a.id.toString(),
          title: a.title,
          artist: a.artistOrUnknown,
          album: a.albumOrUnknown,
          duration: Duration(milliseconds: a.duration ?? 0),
          artUri: Uri.parse("content://media/external/audio/albumart/${a.id}"),
          extras: {'uri': a.uri},
        );
        items.add(mediaItem);

        // Create AudioSource
        if (a.uri == null || a.uri!.isEmpty) {
          throw Exception('Audio URI is null or empty for id: ${a.id}');
        }
        final audioSource = AudioSource.uri(Uri.parse(a.uri!), tag: mediaItem);
        sources.add(audioSource);
      } catch (e) {
        // Log or handle invalid audio gracefully
        // Optionally, continue without adding this audio
        continue;
      }
    }

    if (items.isEmpty || sources.isEmpty) {
      return;
    }

    queue.add(items);

    try {
      await _player.setAudioSource(
        ConcatenatingAudioSource(children: sources),
        initialIndex: initIndex,
      );
    } catch (e) {
      // Handle or notify user
      return;
    }

    if (autoRun) {
      try {
        play();
      } catch (e) {}
    }
  }

  Future<void> playAudio(AudioFile audio) async {
    final index = queue.value.indexWhere(
      (item) => item.id == audio.id.toString(),
    );
    if (index != -1) {
      await _player.seek(Duration.zero, index: index);
      play();
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() async {
    await _player.pause();
    await super.stop(); // يغلق الخدمة ويزيل الإشعار
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    } else {
      await _player.seek(Duration.zero, index: 0);
    }
  }

  @override
  Future<void> skipToPrevious() =>
      _player.hasPrevious
          ? _player.seekToPrevious()
          : _player.seek(
            Duration(seconds: 0),
            index: _player.effectiveIndices!.length - 1,
          );
  @override
  Future<void> onTaskRemoved() async {
    if (!_player.playing) {
      await _player.stop();
      await super.stop();
    }
  }
}
