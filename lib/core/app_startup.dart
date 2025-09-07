import 'package:audio_service/audio_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/playlist.dart';
import 'package:mero_audio_player/features/audio_player/services/audio_handler.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:mero_audio_player/injection.dart' as di;

late final AudioHandler audioHandler;

Future<void> setupApp() async {
  await Hive.initFlutter();
  Hive.registerAdapter(AudioFileAdapter());
  Hive.registerAdapter(PlaylistAdapter());
  await Hive.openBox<Playlist>('playlists');

  await Hive.openBox('audio_player_state');
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.audio.channel',
    androidNotificationChannelName: 'Audio Playback',
    androidNotificationOngoing: true,
  );

  di.setupInjection();

  audioHandler = AudioPlayerHandler();
}
