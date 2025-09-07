import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';

abstract class AudioRepository {
  Future<List<AudioFile>> fetchAudioFiles();
}
