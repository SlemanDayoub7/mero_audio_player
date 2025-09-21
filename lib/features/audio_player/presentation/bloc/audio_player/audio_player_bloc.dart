import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/recently_played_event.dart';
import 'package:mero_audio_player/features/audio_player/domain/repositories/audio_repository.dart';
import 'package:mero_audio_player/features/audio_player/domain/repositories/playlists_repository.dart';
import 'package:mero_audio_player/features/audio_player/services/audio_handler.dart';
import 'package:mero_audio_player/injection.dart';
import '../../../domain/entities/audio_file.dart';
part 'audio_player_event.dart';
part 'audio_player_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayerHandler playerHandler;
  final AudioRepository audioRepository;
  final PlaylistRepository playlistRepository;
  static const _boxName = 'recentlyPlayedBox';
  late Box _box;
  List<AudioFile> currentPlaylist;
  int? currentIndex;
  // Equalizer state
  AudioPlayerBloc({
    required this.playerHandler,
    required this.playlistRepository,
    required this.audioRepository,
    List<AudioFile>? initialPlaylist,
    int? initialIndex,
  }) : currentPlaylist = initialPlaylist ?? [],
       currentIndex = initialIndex,
       super(const AudioPlayerInitial()) {
    _initHive();
    // Listen for track changes
    playerHandler.player.setLoopMode(LoopMode.all);
    playerHandler.player.currentIndexStream.listen((index) {
      currentIndex = index;
      if (index != null && playerHandler.queue.value.isNotEmpty) {
        final mediaItem = playerHandler.queue.value[index];
        final audio = AudioFile(
          id: int.parse(mediaItem.id),
          title: mediaItem.title,
          artist: mediaItem.artist,
          album: mediaItem.album,
          uri: mediaItem.extras?['uri'],
          duration: mediaItem.duration?.inMilliseconds,
        );
        add(_InternalAudioChanged(audio));
      }
    });
    on<PlayAudioRange>((event, emit) async {
      // Set playlist if changed
    });
    on<SetPlaybackSpeed>((event, emit) async {
      await playerHandler.player.setSpeed(event.speed);
      // لو تحب ترجع الحالة الحالية بعد التغيير
      emit(_mapToState(current: state.current));
    });
    // Play audio
    on<PlayAudio>((event, emit) async {
      if (event.audios != currentPlaylist) {
        await playerHandler.setPlaylist(event.audios, autoRun: false);
        currentPlaylist = event.audios;
      }
      if (event.runAutomatically!) {
        await playerHandler.playAudio(event.audio);
      }

      emit(_mapToState(current: event.audio));
    });

    // Pause
    on<PauseAudio>((event, emit) async {
      await playerHandler.pause();
      emit(_mapToState(current: state.current));
    });

    // Resume
    on<ResumeAudio>((event, emit) async {
      await playerHandler.play();
      emit(_mapToState(current: state.current));
    });

    // Stop
    on<StopAudio>((event, emit) async {
      await playerHandler.stop();
      emit(_mapToState(current: state.current));
    });

    // Seek
    on<SeekAudio>((event, emit) async {
      await playerHandler.seek(event.position);
    });

    // Next
    on<NextAudio>((event, emit) async {
      await playerHandler.skipToNext();
      _emitCurrentFromPlayer(emit);
    });

    // Previous
    on<PreviousAudio>((event, emit) async {
      await playerHandler.skipToPrevious();
      _emitCurrentFromPlayer(emit);
    });

    // Internal track change
    on<_InternalAudioChanged>((event, emit) {
      emit(_mapToState(current: event.audio));
    });

    on<TogglePlaybackMode>((event, emit) async {
      switch (event.playbackMode) {
        case PlaybackMode.repeatAll:
          await playerHandler.player.setShuffleModeEnabled(false);
          await playerHandler.player.setLoopMode(LoopMode.all);
          break;
        case PlaybackMode.repeatOne:
          await playerHandler.player.setShuffleModeEnabled(false);
          await playerHandler.player.setLoopMode(LoopMode.one);
          break;
        case PlaybackMode.shuffle:
          await playerHandler.player.setShuffleModeEnabled(true);
          await playerHandler.player.setLoopMode(LoopMode.off);

          break;
      }

      emit(_mapToState(current: state.current));
    });
  }
  // Toggle repeat

  /// Build state with current shuffle & repeat values
  AudioPlayerState _mapToState({required AudioFile? current}) {
    final player = playerHandler.player;
    final speed = player.speed;

    final RecentlyPlayedAudio recentlyPlayedAudio = RecentlyPlayedAudio(
      id: current!.id.toString(),
      playListName: currentPlayListName,
      artist: current.artist ?? '',
      source: playSource!,
    );
    try {
      _box.put('lastPlayed', recentlyPlayedAudio.toMap());
    } catch (e) {}
    return player.playing
        ? AudioPlayerPlaying(
          playSource: playSource!,
          current: current,
          playbackMode: playbackMode!,
          speed: speed,
        )
        : AudioPlayerPaused(
          current: current,
          playSource: playSource!,
          playbackMode: playbackMode!,
          speed: speed,
        );
  }

  Future<void> _initHive() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
    // try {
    //   final Map<String, dynamic>? storedMap =
    //       _box.get('lastPlayed')?.cast<String, dynamic>();
    //   if (storedMap == null) {
    //     return;
    //   }

    //   RecentlyPlayedAudio audio = RecentlyPlayedAudio.fromMap(storedMap);

    //   // Implement your check here to verify if audio exists on device, e.g.:
    //   final exists = await _checkIfAudioExists(audio.id);
    //   if (!exists) {
    //     await _box.delete('lastPlayed');
    //     return;
    //   }
    //   List<AudioFile> audios = [];
    //   switch (audio.source) {
    //     case PlaySource.artist:
    //       audios = await audioRepository.fetchSongsByArtist(audio.artist);
    //       break;
    //     case PlaySource.audioList:
    //       audios = await audioRepository.fetchAudioFiles();
    //       break;
    //     case PlaySource.playlist:
    //       List<Playlist> playLists = await playlistRepository.getAllPlaylists();

    //       break;
    //   }
    //   currentPlaylist = audios;
    //   print(audio.id);
    //   int ind = 0;
    //   for (AudioFile i in audios) {
    //     if (i.id.toString() == audio.id) {
    //       currentIndex = ind;
    //       break;
    //     }
    //     ind++;
    //   }
    //   print(ind);
    //   await playerHandler.setPlaylist(audios, autoRun: false);
    //   if (currentIndex != null) {
    //     await playerHandler.player.seek(Duration.zero, index: currentIndex);
    //     // Optionally emit state for that audio:
    //     final mediaItem = playerHandler.queue.value[currentIndex!];
    //     final audio = AudioFile(
    //       id: int.parse(mediaItem.id),
    //       title: mediaItem.title,
    //       artist: mediaItem.artist,
    //       album: mediaItem.album,
    //       uri: mediaItem.extras?['uri'],
    //       duration: mediaItem.duration?.inMilliseconds,
    //     );
    //     add(_InternalAudioChanged(audio)); // so UI updates immediately
    //   }
    //   ;
    // } catch (e) {}
  }

  void _emitCurrentFromPlayer(Emitter<AudioPlayerState> emit) async {
    final index = playerHandler.player.currentIndex;
    if (index != null && playerHandler.queue.value.isNotEmpty) {
      final mediaItem = playerHandler.queue.value[index];
      final audio = AudioFile(
        id: int.parse(mediaItem.id),
        title: mediaItem.title,
        artist: mediaItem.artist,
        album: mediaItem.album,
        uri: mediaItem.extras?['uri'],
        duration: mediaItem.duration?.inMilliseconds,
      );

      emit(_mapToState(current: audio));
    }
  }
}

Future<bool> _checkIfAudioExists(String audioId) async {
  // Implement device or repository check whether audio file still exists
  // Return true if exists, false if deleted/missing
  return true; // Placeholder for demo
}
