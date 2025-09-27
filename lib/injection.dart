import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:mero_audio_player/core/locale_cubit.dart';
import 'package:mero_audio_player/features/audio_player/data/repositories/playlist_repository_impl.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';

import 'package:mero_audio_player/features/audio_player/domain/entities/playlist.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/recently_played_event.dart';
import 'package:mero_audio_player/features/audio_player/domain/repositories/audiobook_repository.dart';
import 'package:mero_audio_player/features/audio_player/domain/repositories/playlists_repository.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/album_list/album_list_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/artist_list/artist_list_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/recently_played/recently_played_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/recently_played/recently_played_event.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/ringtone/ringtone_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/change_background_page.dart';
import 'package:mero_audio_player/features/audio_player/services/audio_handler.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'features/audio_player/data/repositories/audio_repository_impl.dart';
import 'features/audio_player/domain/entities/chapter.dart';
import 'features/audio_player/domain/repositories/audio_repository.dart';
import 'features/audio_player/presentation/bloc/audio_list/audio_list_bloc.dart';
import 'features/audio_player/presentation/bloc/audio_player/audio_player_bloc.dart';

late final AudioPlayer audiobookPlayer;
SongSortType? selectedSort;
OrderType orderType = OrderType.ASC_OR_SMALLER;
PlaybackMode? playbackMode = PlaybackMode.repeatAll;
PlaySource? playSource = PlaySource.audioList;
String currentPlayListName = '';

List<AudioFile> _audios = [];
int? _savedIndex;

class Injection {
  static late final AudioRepository audioRepository;
  static late final AudioPlayerHandler audioHandler;
  static late final PlaylistRepository playlistRepository;
  static late final AudiobookRepository audiobookRepository;

  /// Call this once at app start
  static Future<void> init() async {
    audiobookPlayer = AudioPlayer();
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.mero_audio_player.channel.audio',
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    );

    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters BEFORE opening boxes
    Hive.registerAdapter(ChapterAdapter());
    Hive.registerAdapter(PlaylistAdapter());
    Hive.registerAdapter(AudioFileAdapter());

    // Open Hive boxes
    await Hive.openBox<Playlist>('playlists');
    await Hive.openBox('backgroundBox');
    await Hive.openBox('sortType');
    await Hive.openBox('settings');
    final savedIndexSortType = Hive.box(
      'settings',
    ).get('sortType', defaultValue: 0);
    final savedIndexOrderType = Hive.box(
      'settings',
    ).get('orderType', defaultValue: 0);

    selectedSort = SongSortType.values[savedIndexSortType];
    orderType = OrderType.values[savedIndexOrderType];
    Box backgroundBox = Hive.box(backgroundBoxName);
    int? savedColorValue = backgroundBox.get(backgroundColorKey);
    String? savedImage = backgroundBox.get(backgroundImageKey);
    String? savedLottie = backgroundBox.get(lottieKey);
    if (savedLottie != null) globalLottiePath = savedLottie;
    if (savedColorValue != null) {
      globalBackgroundColor = Color(savedColorValue);
    } else {
      globalBackgroundColor = Color(0xFF121212);
    }
    if (savedImage != null && savedImage.isNotEmpty) {
      globalBackgroundImagePath = savedImage;
    } else {
      globalBackgroundImagePath = 'assets/images/mate.jpg';
    }
    // Repositories
    audioRepository = AudioRepositoryImpl();

    playlistRepository = PlaylistRepositoryImpl();

    // Audio handler
    audioHandler = AudioPlayerHandler();
    // 👇 restore last played before UI builds
    try {
      final box = await Hive.openBox('recentlyPlayedBox');
      final map = box.get('lastPlayed')?.cast<String, dynamic>();
      if (map != null) {
        final last = RecentlyPlayedAudio.fromMap(map);

        // fetch audios depending on source

        switch (last.source) {
          case PlaySource.artist:
            _audios = await audioRepository.fetchSongsByArtist(last.artist);
            break;
          case PlaySource.audioList:
            _audios = await audioRepository.fetchAudioFiles();
            break;
          case PlaySource.playlist:
            final playlists = await playlistRepository.getAllPlaylists();
            _audios =
                playlists.lastWhere((e) => e.name == last.playListName!).audios;
            break;
          case PlaySource.album:
            _audios = await audioRepository.fetchSongsByAlbum(last.album);
            break;
        }

        // find saved index

        for (var i = 0; i < _audios.length; i++) {
          if (_audios[i].id.toString() == last.id) {
            _savedIndex = i;
            break;
          }
        }

        if (_audios.isNotEmpty && _savedIndex != null) {
          await audioHandler.setPlaylist(
            _audios,
            autoRun: false,
            initIndex: _savedIndex,
          );
        }
      } else {
        _audios = await audioRepository.fetchAudioFiles();
        if (_audios.isNotEmpty) {
          await audioHandler.setPlaylist(_audios, autoRun: false, initIndex: 0);
        }
      }
    } catch (e) {}
  }

  /// Bloc providers for MultiBlocProvider
  static List<BlocProvider> getProviders(BuildContext context) => [
    BlocProvider<LocaleCubit>(
      create: (_) => LocaleCubit(context.savedLocale ?? context.locale),
    ),
    BlocProvider<AudioListBloc>(
      create:
          (_) =>
              AudioListBloc(repository: audioRepository)..add(FetchAudioList()),
    ),
    BlocProvider<AudioPlayerBloc>(
      create:
          (_) => AudioPlayerBloc(
            playerHandler: audioHandler,
            playlistRepository: playlistRepository,
            audioRepository: audioRepository,
            initialPlaylist: _audios,
            initialIndex: _savedIndex,
          ),
    ),
    BlocProvider<PlaylistBloc>(
      create:
          (_) =>
              PlaylistBloc(repository: playlistRepository)
                ..add(LoadPlaylists()),
    ),
    BlocProvider<ArtistListBloc>(
      create:
          (context) =>
              ArtistListBloc(repository: audioRepository)
                ..add(FetchArtistList()),
    ),
    BlocProvider<AlbumListBloc>(
      create:
          (context) =>
              AlbumListBloc(repository: audioRepository)..add(FetchAlbumList()),
    ),
    // BlocProvider<SetRingToneBloc>(create: (context) => SetRingToneBloc()),
  ];
}
