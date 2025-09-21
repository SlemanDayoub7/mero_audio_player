import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/playlist.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/recently_played_event.dart';
import 'package:mero_audio_player/features/audio_player/domain/repositories/audio_repository.dart';
import 'package:mero_audio_player/features/audio_player/domain/repositories/playlists_repository.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/recently_played/recently_played_event.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/recently_played/recently_played_state.dart';

class RecentlyPlayedBloc
    extends Bloc<RecentlyPlayedEvent, RecentlyPlayedState> {
  static const _boxName = 'recentlyPlayedBox';
  late Box _box;

  final PlaylistRepository playlistRepository;
  final AudioRepository audioRepository;
  RecentlyPlayedBloc({
    required this.playlistRepository,
    required this.audioRepository,
  }) : super(RecentlyPlayedInitial()) {
    on<LoadRecentlyPlayed>(_onLoad);
    on<SetRecentlyPlayed>(_onSet);
    on<ClearRecentlyPlayed>(_onClear);
    _initHive();
  }

  Future<void> _initHive() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
    add(LoadRecentlyPlayed());
  }

  Future<void> _onLoad(
    LoadRecentlyPlayed event,
    Emitter<RecentlyPlayedState> emit,
  ) async {
    emit(RecentlyPlayedLoading());
    try {
      final Map<String, dynamic>? storedMap =
          _box.get('lastPlayed')?.cast<String, dynamic>();
      if (storedMap == null) {
        emit(RecentlyPlayedLoaded(audio: null, audios: []));
        return;
      }

      RecentlyPlayedAudio audio = RecentlyPlayedAudio.fromMap(storedMap);

      // Implement your check here to verify if audio exists on device, e.g.:
      final exists = await _checkIfAudioExists(audio.id);
      if (!exists) {
        await _box.delete('lastPlayed');
        emit(RecentlyPlayedLoaded(audio: null, audios: []));
        return;
      }
      List<AudioFile> audios = [];
      switch (audio.source) {
        case PlaySource.artist:
          audios = await audioRepository.fetchSongsByArtist(audio.artist);
          break;
        case PlaySource.audioList:
          audios = await audioRepository.fetchAudioFiles();
          break;
        case PlaySource.playlist:
          List<Playlist> playLists = await playlistRepository.getAllPlaylists();

          break;
      }
      emit(RecentlyPlayedLoaded(audio: audio, audios: audios));
    } catch (e) {
      emit(RecentlyPlayedError('Failed to load last played audio'));
    }
  }

  Future<void> _onSet(
    SetRecentlyPlayed event,
    Emitter<RecentlyPlayedState> emit,
  ) async {
    try {
      await _box.put('lastPlayed', event.audio.toMap());
      emit(RecentlyPlayedLoaded(audio: event.audio, audios: []));
    } catch (e) {
      emit(RecentlyPlayedError('Failed to save last played audio'));
    }
  }

  Future<void> _onClear(
    ClearRecentlyPlayed event,
    Emitter<RecentlyPlayedState> emit,
  ) async {
    await _box.delete('lastPlayed');
    emit(RecentlyPlayedLoaded(audio: null, audios: []));
  }

  Future<bool> _checkIfAudioExists(String audioId) async {
    // Implement device or repository check whether audio file still exists
    // Return true if exists, false if deleted/missing
    return true; // Placeholder for demo
  }
}
