import 'package:mero_audio_player/features/music_library/domain/entities/audio_file/audio_file.dart';
import 'package:mero_audio_player/features/music_library/domain/repositories/audio_repository.dart';

class GetAudioFiles {
  final AudioRepository repository;

  GetAudioFiles(this.repository);

  Future<List<AudioFile>> call() async {
    return await repository.fetchAudioFiles();
  }
}
