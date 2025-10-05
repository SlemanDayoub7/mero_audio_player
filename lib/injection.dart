import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:equalizer_flutter/equalizer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:mero_audio_player/core/locale_cubit.dart';
import 'package:mero_audio_player/features/audio_player/data/repositories/playlist_repository_impl.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/artwork.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/playlist.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/recently_played_event.dart';
import 'package:mero_audio_player/features/audio_player/domain/repositories/audiobook_repository.dart';
import 'package:mero_audio_player/features/audio_player/domain/repositories/playlists_repository.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/album_list/album_list_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/artist_list/artist_list_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/change_background_page.dart';
import 'package:mero_audio_player/features/audio_player/services/audio_handler.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
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

List<AudioFile> tempAudios = [];
List<AudioFile> fulltempAudios = [];
int? _savedIndex;
Future<String?> loadAssetAsFile(String assetPath) async {
  try {
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/mate.png');

    // كتابة محتوى الصورة إلى ملف مؤقت
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  } catch (e) {
    return null;
  }
}

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
      // androidNotificationOngoing: true,
      androidStopForegroundOnPause: false,
      notificationColor: Colors.white,
    );

    // Initialize Hive
    // await Hive.initFlutter();

    // Register adapters BEFORE opening boxes
    Hive.registerAdapter(ChapterAdapter());
    Hive.registerAdapter(PlaylistAdapter());
    Hive.registerAdapter(AudioFileAdapter());
    Hive.registerAdapter(ArtworkAdapter());

    // Open Hive boxes
    await Hive.openBox<Playlist>('playlists');
    await Hive.openBox('backgroundBox');
    await Hive.openBox('sortType');
    await Hive.openBox('settings');
    await Hive.openBox<Artwork>('artworks');
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
      globalBackgroundImagePath = 'assets/images/mate.png';
    }
    // Repositories
    audioRepository = AudioRepositoryImpl();

    playlistRepository = PlaylistRepositoryImpl();
    EqualizerFlutter.init(0);
    EqualizerFlutter.setEnabled(false);
    // Audio handler
    audioHandler = AudioPlayerHandler();
    placeArtwork = await loadAssetAsFile('assets/images/logo.png') ?? '';
    // 👇 restore last played before UI builds
    fulltempAudios = await audioRepository.fetchAudioFiles();
    try {
      final box = await Hive.openBox('recentlyPlayedBox');
      final map = box.get('lastPlayed')?.cast<String, dynamic>();
      if (map != null) {
        final last = RecentlyPlayedAudio.fromMap(map);

        // fetch audios depending on source

        switch (last.source) {
          case PlaySource.artist:
            playSource = PlaySource.artist;
            tempAudios = await audioRepository.fetchSongsByArtist(last.artist);
            break;
          case PlaySource.audioList:
            playSource = PlaySource.audioList;
            tempAudios = fulltempAudios;
            break;
          case PlaySource.playlist:
            playSource = PlaySource.playlist;
            final playlists = await playlistRepository.getAllPlaylists();
            tempAudios =
                playlists.lastWhere((e) => e.name == last.playListName!).audios;
            break;
          case PlaySource.album:
            playSource = PlaySource.album;
            tempAudios = await audioRepository.fetchSongsByAlbum(last.album);
            break;
        }

        // find saved index

        _savedIndex = tempAudios.indexWhere((e) => e.id.toString() == last.id);

        if (tempAudios.isNotEmpty && _savedIndex != -1) {
          await audioHandler.setPlaylist(
            tempAudios,
            autoRun: false,
            initIndex: _savedIndex,
          );
        }
      } else {
        if (fulltempAudios.isNotEmpty) {
          await audioHandler.setPlaylist(
            fulltempAudios,
            autoRun: false,
            initIndex: 0,
          );
        }
      }
    } catch (e) {
      if (fulltempAudios.isNotEmpty) {
        await audioHandler.setPlaylist(
          fulltempAudios,
          autoRun: false,
          initIndex: 0,
        );
      }
    }
  }

  /// Bloc providers for MultiBlocProvider
  static List<BlocProvider> getProviders(BuildContext context) => [
    BlocProvider<LocaleCubit>(
      create: (_) => LocaleCubit(context.savedLocale ?? context.locale),
    ),
    BlocProvider<AudioListBloc>(
      create:
          (_) =>
              AudioListBloc(repository: audioRepository)
                ..add(LoadAudioList(fulltempAudios)),
    ),
    BlocProvider<AudioPlayerBloc>(
      create:
          (_) => AudioPlayerBloc(
            playerHandler: audioHandler,
            playlistRepository: playlistRepository,
            audioRepository: audioRepository,
            initialPlaylist: tempAudios,
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
