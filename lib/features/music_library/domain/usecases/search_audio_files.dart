import 'package:mero_audio_player/features/music_library/domain/entities/audio_file/audio_file.dart';

class SearchAudioFiles {
  List<AudioFile> call({
    required List<AudioFile> audios,
    required String query,
  }) {
    final lowercaseQuery = query.toLowerCase();
    return audios.where((audio) {
      final title = audio.title.toLowerCase();
      final artist = audio.artistOrUnknown.toLowerCase();
      final album = audio.albumOrUnknown.toLowerCase();
      return title.contains(lowercaseQuery) ||
          artist.contains(lowercaseQuery) ||
          album.contains(lowercaseQuery);
    }).toList();
  }
}
