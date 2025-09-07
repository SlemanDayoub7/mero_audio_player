import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';

class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final _player = AudioPlayer();
  AudioPlayer get player => _player;
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
    int startIndex = 0,
    bool autoRun = true,
  }) async {
    final items =
        audios.map((a) {
          return MediaItem(
            id: a.id.toString(),
            title: a.title,
            artist: a.artistOrUnknown,
            album: a.albumOrUnknown,
            duration: Duration(milliseconds: a.duration ?? 0),
            artUri: Uri.parse(
              "content://media/external/audio/albumart/${a.id}",
            ),
            extras: {'uri': a.uri},
          );
        }).toList();

    queue.add(items);

    final sources =
        audios.map((a) {
          return AudioSource.uri(
            Uri.parse(a.uri ?? ""),
            tag: MediaItem(
              id: a.id.toString(),
              title: a.title,
              artist: a.artistOrUnknown,
              album: a.albumOrUnknown,
              duration: Duration(milliseconds: a.duration ?? 0),
            ),
          );
        }).toList();

    await _player.setAudioSource(
      ConcatenatingAudioSource(children: sources),
      initialIndex: startIndex,
    );

    if (autoRun) play();
  }

  @override
  Future<void> play() async {
    _player.play();
  }

  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> stop() => _player.stop();
  @override
  Future<void> seek(Duration position) => _player.seek(position);
  @override
  Future<void> skipToNext() async {
    if (_player.hasNext) {
      _player.seekToNext();
    } else {
      _player.seek(Duration(seconds: 0), index: 0);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.hasPrevious) {
      _player.seekToPrevious();
    } else {
      _player.seek(
        Duration(seconds: 0),
        index: _player.audioSource!.sequence.length - 1,
      );
    }
  }
}
