import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equalizer_flutter/equalizer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mero_audio_player/core/constants/app_constants.dart';
import 'package:mero_audio_player/core/constants/hive_boxes.dart';
import 'package:mero_audio_player/core/localization/locale_cubit.dart';
import 'package:mero_audio_player/core/services/audio_handler.dart';
import 'package:mero_audio_player/core/utils/artwork_utils.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/recently_played/recently_played_event.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/audio_player/audio_player_bloc.dart';
import 'package:mero_audio_player/features/music_library/data/repositories/audio_repository_impl.dart';
import 'package:mero_audio_player/features/music_library/domain/entities/artwork/artwork.dart';
import 'package:mero_audio_player/features/music_library/domain/entities/audio_file/audio_file.dart';
import 'package:mero_audio_player/features/music_library/domain/repositories/audio_repository.dart';
import 'package:mero_audio_player/features/music_library/domain/usecases/album_list_usecases/fetch_albums.dart';
import 'package:mero_audio_player/features/music_library/domain/usecases/album_list_usecases/fetch_songs_by_album.dart';
import 'package:mero_audio_player/features/music_library/domain/usecases/album_list_usecases/search_albums.dart';
import 'package:mero_audio_player/features/music_library/domain/usecases/artist_list_usecases/fetch_artists.dart';
import 'package:mero_audio_player/features/music_library/domain/usecases/artist_list_usecases/fetch_songs_by_artist.dart';
import 'package:mero_audio_player/features/music_library/domain/usecases/artist_list_usecases/search_artists.dart';
import 'package:mero_audio_player/features/music_library/domain/usecases/audio_list_usecases/get_audio_files.dart';
import 'package:mero_audio_player/features/music_library/domain/usecases/audio_list_usecases/search_audio_files.dart';
import 'package:mero_audio_player/features/music_library/domain/usecases/audio_list_usecases/sort_audio_files.dart';
import 'package:mero_audio_player/features/music_library/presentation/bloc/album_list/album_list_bloc.dart';
import 'package:mero_audio_player/features/music_library/presentation/bloc/artist_list/artist_list_bloc.dart';
import 'package:mero_audio_player/features/music_library/presentation/bloc/audio_list/audio_list_bloc.dart';
import 'package:mero_audio_player/features/playlist/data/repositories/playlist_repository_impl.dart';
import 'package:mero_audio_player/features/playlist/domain/entities/chapter/chapter.dart';
import 'package:mero_audio_player/features/playlist/domain/entities/playlist/playlist.dart';
import 'package:mero_audio_player/features/playlist/domain/repositories/playlists_repository.dart';
import 'package:mero_audio_player/features/playlist/presentation/bloc/playlist_bloc.dart';
import 'package:mero_audio_player/features/settings/presentation/pages/change_background/change_background_page.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';
import 'package:on_audio_query/on_audio_query.dart';
// Lyrics feature imports
import 'package:mero_audio_player/features/lyrics/data/datasources/lyrics_local_datasource.dart';
import 'package:mero_audio_player/features/lyrics/data/datasources/lyrics_remote_datasource.dart';
import 'package:mero_audio_player/features/lyrics/data/repositories/lyrics_repository_impl.dart';
import 'package:mero_audio_player/features/lyrics/domain/repositories/lyrics_repository.dart';
import 'package:mero_audio_player/features/lyrics/domain/usecases/fetch_lyrics.dart';
import 'package:mero_audio_player/features/lyrics/presentation/bloc/lyrics_bloc.dart';

// 🧠 Global service locator
final sl = GetIt.instance;

// 🔁 Previously global variables (unchanged)
SongSortType? selectedSort;
OrderType orderType = OrderType.ASC_OR_SMALLER;
PlaybackMode? playbackMode = PlaybackMode.repeatAll;
PlaySource? playSource = PlaySource.audioList;
String currentPlayListName = '';

List<AudioFile> _tempAudios = [];
List<AudioFile> _fulltempAudios = [];
int? _savedIndex;

class Injection {
  static late final AudioPlayerHandler audioHandler;
  static Future<void> init() async {
    _initEqualizer();
    placeArtwork =
        await ArtworkUtils.loadAssetAsFile(Assets.images.logo.path) ?? '';
    await _initAudioService();
    await _initHiveBoxes();
    _fetchSavedOptions();
    _initRepositories();
    _initUsecases();
    _initLyricsFeature();

    await _fetchLastPlayedAudio();
  }

  static Future<void> _initAudioService() async {
    audioHandler = await AudioService.init(
      builder: () => AudioPlayerHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: AppConstants.androidNotificationChannelId,
        androidNotificationChannelName:
            AppConstants.androidNotificationChannelName,
        androidStopForegroundOnPause: AppConstants.androidStopForegroundOnPause,
      ),
    );
  }

  static Future<void> _initHiveBoxes() async {
    Hive.registerAdapter(ChapterAdapter());
    Hive.registerAdapter(PlaylistAdapter());
    Hive.registerAdapter(AudioFileAdapter());
    Hive.registerAdapter(ArtworkAdapter());

    await Hive.openBox<Playlist>(HiveBoxes.playlists);
    await Hive.openBox(HiveBoxes.background);
    await Hive.openBox(HiveBoxes.sortType);
    await Hive.openBox(HiveBoxes.settings);
    await Hive.openBox<Artwork>(HiveBoxes.artworks);
  }

  static void _initRepositories() {
    sl.registerLazySingleton<AudioRepository>(() => AudioRepositoryImpl());
    sl.registerLazySingleton<PlaylistRepository>(
      () => PlaylistRepositoryImpl(),
    );
  }

  static void _initUsecases() {
    sl.registerLazySingleton(() => GetAudioFiles(sl()));
    sl.registerLazySingleton(() => SortAudioFiles());
    sl.registerLazySingleton(() => SearchAudioFiles(sl()));
    // Album-related
    sl.registerLazySingleton(() => FetchAlbums(sl()));
    sl.registerLazySingleton(() => FetchSongsByAlbum(sl()));
    sl.registerLazySingleton(() => SearchAlbums());
    // Artist-related
    sl.registerLazySingleton(() => FetchArtists(sl()));
    sl.registerLazySingleton(() => FetchSongsByArtist(sl()));
    sl.registerLazySingleton(() => SearchArtists());
  }

  /// Initialize Lyrics Feature
  static void _initLyricsFeature() {
    // Dio instance for HTTP requests
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    sl.registerSingleton<Dio>(dio);

    // Data sources
    sl.registerSingleton<LyricsLocalDatasource>(
      LyricsLocalDatasourceImpl(),
    );
    sl.registerSingleton<LyricsRemoteDatasource>(
      LyricsRemoteDatasourceImpl(sl<Dio>()),
    );

    // Repository
    sl.registerLazySingleton<LyricsRepository>(
      () => LyricsRepositoryImpl(
        localDatasource: sl<LyricsLocalDatasource>(),
        remoteDatasource: sl<LyricsRemoteDatasource>(),
      ),
    );

    // Usecases
    sl.registerLazySingleton<FetchLyrics>(
      () => FetchLyrics(sl<LyricsRepository>()),
    );
  }

  static void _initEqualizer() {
    EqualizerFlutter.init(0);
    EqualizerFlutter.setEnabled(false);
  }

  static void _fetchSavedOptions() {
    final settingsBox = Hive.box(HiveBoxes.settings);
    final savedIndexSortType = settingsBox.get(
      HiveBoxes.sortType,
      defaultValue: 0,
    );
    final savedIndexOrderType = settingsBox.get(
      HiveBoxes.orderType,
      defaultValue: 0,
    );

    selectedSort = SongSortType.values[savedIndexSortType];
    orderType = OrderType.values[savedIndexOrderType];

    final backgroundBox = Hive.box(backgroundBoxName);
    int? savedColorValue = backgroundBox.get(backgroundColorKey);
    String? savedImage = backgroundBox.get(backgroundImageKey);
    String? savedLottie = backgroundBox.get(lottieKey);

    if (savedLottie != null) globalLottiePath = savedLottie;
    if (savedColorValue != null) {
      globalBackgroundColor = Color(savedColorValue);
    } else {
      globalBackgroundColor = const Color(0xFF121212);
    }
    if (savedImage != null && savedImage.isNotEmpty) {
      globalBackgroundImagePath = savedImage;
    } else {
      globalBackgroundImagePath = Assets.images.mate.path;
    }
  }

  static Future<void> _fetchLastPlayedAudio() async {
    final audioRepository = sl<AudioRepository>();
    final playlistRepository = sl<PlaylistRepository>();
    // final audioHandler = sl<AudioPlayerHandler>();

    _fulltempAudios = await audioRepository.fetchAudioFiles();
    try {
      final box = await Hive.openBox(HiveBoxes.recentlyPlayed);
      final map = box.get(HiveBoxes.lastPlayed)?.cast<String, dynamic>();
      if (map != null) {
        final last = RecentlyPlayedAudio.fromMap(map);

        switch (last.source) {
          case PlaySource.artist:
            playSource = PlaySource.artist;
            _tempAudios = await audioRepository.fetchSongsByArtist(last.artist);
            break;
          case PlaySource.audioList:
            playSource = PlaySource.audioList;
            _tempAudios = _fulltempAudios;
            break;
          case PlaySource.playlist:
            playSource = PlaySource.playlist;
            final playlists = await playlistRepository.getAllPlaylists();
            _tempAudios =
                playlists.lastWhere((e) => e.name == last.playListName!).audios;
            break;
          case PlaySource.album:
            playSource = PlaySource.album;
            _tempAudios = await audioRepository.fetchSongsByAlbum(last.album);
            break;
        }

        _savedIndex = _tempAudios.indexWhere((e) => e.id.toString() == last.id);

        if (_tempAudios.isNotEmpty && _savedIndex != -1) {
          await audioHandler.setPlaylist(
            _tempAudios,
            autoRun: false,
            initIndex: _savedIndex,
          );
        }
      } else {
        if (_fulltempAudios.isNotEmpty) {
          await audioHandler.setPlaylist(
            _fulltempAudios,
            autoRun: false,
            initIndex: 0,
          );
        }
      }
    } catch (e) {
      if (_fulltempAudios.isNotEmpty) {
        await audioHandler.setPlaylist(
          _fulltempAudios,
          autoRun: false,
          initIndex: 0,
        );
      }
    }
  }

  /// Bloc providers (same logic)
  static List<BlocProvider> getProviders(BuildContext context) => [
    BlocProvider<LocaleCubit>(
      create: (_) => LocaleCubit(context.savedLocale ?? context.locale),
    ),
    BlocProvider<AudioListBloc>(
      create:
          (_) => AudioListBloc(
            repository: sl(),
            getAudioFiles: sl(),
            sortAudioFiles: sl(),
            searchAudioFiles: sl(),
          )..add(LoadAudioList(_fulltempAudios)),
    ),
    BlocProvider<AudioPlayerBloc>(
      create:
          (_) => AudioPlayerBloc(
            playerHandler: audioHandler,
            playlistRepository: sl(),
            audioRepository: sl(),
            initialPlaylist: _tempAudios,
            initialIndex: _savedIndex,
          ),
    ),
    BlocProvider<PlaylistBloc>(
      create: (_) => PlaylistBloc(repository: sl())..add(LoadPlaylists()),
    ),
    BlocProvider<ArtistListBloc>(
      create:
          (_) => ArtistListBloc(
            searchArtists: sl(),
            fetchArtists: sl(),
            fetchSongsByArtist: sl(),
          )..add(FetchArtistList()),
    ),
    BlocProvider<AlbumListBloc>(
      create:
          (_) => AlbumListBloc(
            searchAlbums: sl(),
            fetchAlbums: sl(),
            fetchSongsByAlbum: sl(),
          )..add(FetchAlbumList()),
    ),
    BlocProvider<LyricsBloc>(
      create: (_) => LyricsBloc(fetchLyricsUsecase: sl<FetchLyrics>()),
    ),
  ];
}
