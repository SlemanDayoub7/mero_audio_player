import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:mero_audio_player/features/music_library/data/repositories/audio_repository_impl.dart';
import 'package:mero_audio_player/features/music_library/domain/entities/audio_file/audio_file.dart';

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

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  AudioPlayerHandler() {
    _player.playerStateStream.listen((state) {
      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            state.playing ? MediaControl.pause : MediaControl.play,
            MediaControl.skipToNext,
            MediaControl.stop,
          ],
          systemActions: const {MediaAction.seek},
          playing: state.playing,
          processingState:
              {
                ProcessingState.idle: AudioProcessingState.idle,
                ProcessingState.loading: AudioProcessingState.loading,
                ProcessingState.buffering: AudioProcessingState.buffering,
                ProcessingState.ready: AudioProcessingState.ready,
                ProcessingState.completed: AudioProcessingState.completed,
              }[state.processingState]!,
          repeatMode:
              const {
                LoopMode.off: AudioServiceRepeatMode.none,
                LoopMode.one: AudioServiceRepeatMode.one,
                LoopMode.all: AudioServiceRepeatMode.all,
              }[_player.loopMode]!,
          shuffleMode:
              (_player.shuffleModeEnabled)
                  ? AudioServiceShuffleMode.all
                  : AudioServiceShuffleMode.none,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: _player.currentIndex,
        ),
      );
    });

    _player.currentIndexStream.listen((currentIndex) {
      final playlist = queue.value;
      if (currentIndex == null || playlist.isEmpty) return;

      // Just Audio: the tag of the currently playing AudioSource holds the MediaItem
      final currentSource = _player.sequence?[currentIndex];
      if (currentSource == null) {
        return;
      }

      final currentMediaItem = currentSource.tag as MediaItem;

      // Update media item in notification
      mediaItem.add(currentMediaItem);

      // Update playbackState with correct queue index
      playbackState.add(
        playbackState.value.copyWith(
          queueIndex: currentIndex,
          updatePosition: _player.position,
        ),
      );
    });
  }

  Future<void> setPlaylist(
    List<AudioFile> audios, {
    bool autoRun = true,
    int? initIndex,
  }) async {
    if (audios.isEmpty) return;

    // 1️⃣ Stop current playback and clear previous queue
    await _player.stop();
    await _player.seek(Duration.zero);
    queue.add([]); // Clear audio_service queue

    final items = <MediaItem>[];
    final sources = <AudioSource>[];

    for (var a in audios) {
      try {
        int index = artworks.indexWhere((e) => e.id == a.id);
        var uri = Uri.file(placeArtwork);
        if (index != -1) {
          uri = Uri.file(artworks[index].artworkFilePath ?? placeArtwork);
        }

        final mediaItem = MediaItem(
          id: a.id.toString(),
          title: a.title,
          artist: a.artistOrUnknown,
          album: a.albumOrUnknown,
          duration: Duration(milliseconds: a.duration ?? 0),
          artUri: uri,
          extras: {'uri': a.uri},
        );
        items.add(mediaItem);

        if (a.uri == null || a.uri!.isEmpty) continue;

        final audioSource = AudioSource.uri(Uri.parse(a.uri!), tag: mediaItem);
        sources.add(audioSource);
      } catch (e) {
        print('Error adding audio ${a.id}: $e');
        continue;
      }
    }

    if (sources.isEmpty) return;

    // 2️⃣ Update the queue (for AudioService notifications)
    queue.add(items);

    // 3️⃣ Build and load new concatenating source
    try {
      final newSource = ConcatenatingAudioSource(children: sources);
      await _player.setAudioSource(newSource, initialIndex: initIndex);
    } catch (e) {
      print('Error setting audio source: $e');
      return;
    }

    // 4️⃣ Reset internal state to match new queue
    playbackState.add(
      playbackState.value.copyWith(
        queueIndex: initIndex ?? 0,
        updatePosition: Duration.zero,
      ),
    );

    // 5️⃣ Auto-play if requested
    if (autoRun) {
      try {
        await _player.play();
      } catch (e) {
        print('Error starting playback: $e');
      }
    }

    // 6️⃣ Force media item update for notification
    if (initIndex != null && items.isNotEmpty) {
      mediaItem.add(items[initIndex]);
    } else if (items.isNotEmpty) {
      mediaItem.add(items.first);
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
    print('object');

    await _player.pause();
    await super.pause();
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
}
