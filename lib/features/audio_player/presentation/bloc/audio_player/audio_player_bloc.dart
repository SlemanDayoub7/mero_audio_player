import 'package:bloc/bloc.dart';
import 'package:equalizer_flutter/equalizer_flutter.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';

import 'package:mero_audio_player/features/audio_player/domain/entities/recently_played/recently_played_event.dart';
import 'package:mero_audio_player/features/music_library/domain/repositories/audio_repository.dart';
import 'package:mero_audio_player/features/playlist/domain/repositories/playlists_repository.dart';
import 'package:mero_audio_player/core/services/audio_handler.dart';
import 'package:mero_audio_player/core/di/injection.dart';
import '../../../../music_library/domain/entities/audio_file/audio_file.dart';
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
      album: current.album ?? '',
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

  @override
  Future<void> close() {
    EqualizerFlutter.release();
    EqualizerFlutter.setEnabled(false);
    EqualizerFlutter.removeAudioSessionId(0);

    return super.close();
  }
}
