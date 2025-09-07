// data/repositories/audio_repository_impl.dart
import 'package:on_audio_query/on_audio_query.dart';
import '../../domain/entities/audio_file.dart';
import '../../domain/repositories/audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  // ضع هنا أي مجلدات تريد استبعادها
  final List<String> _excludedFolders = [
    '/WhatsApp/Media/WhatsApp Audio/',
    '/Download/',
  ];

  @override
  Future<List<AudioFile>> fetchAudioFiles() async {
    bool perm = await _audioQuery.permissionsStatus();
    if (!perm) {
      perm = await _audioQuery.permissionsRequest();
      if (!perm) throw Exception('Permission denied');
    }

    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    );

    // فلترة المسارات الغير مرغوبة
    final filteredSongs =
        songs.where((song) {
          if (song.data == null) return false;
          return !_excludedFolders.any((folder) => song.data!.contains(folder));
        }).toList();

    return filteredSongs.map((song) => AudioFile.fromSongModel(song)).toList();
  }
}
