// features/music_library/domain/usecases/sort_audio_files.dart
import 'package:mero_audio_player/features/music_library/domain/entities/audio_file/audio_file.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SortAudioFiles {
  List<AudioFile> call({
    required List<AudioFile> audios,
    required SongSortType sortType,
    required OrderType orderType,
  }) {
    List<AudioFile> sortedList = List.from(audios);

    switch (sortType) {
      case SongSortType.ARTIST:
        sortedList.sort(
          (a, b) => a.artistOrUnknown.toLowerCase().compareTo(
            b.artistOrUnknown.toLowerCase(),
          ),
        );
        break;
      case SongSortType.DATE_ADDED:
        sortedList.sort((a, b) => a.dateAdded!.compareTo(b.dateAdded!));
        break;
      case SongSortType.TITLE:
        sortedList.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case SongSortType.ALBUM:
        sortedList.sort(
          (a, b) => a.albumOrUnknown.toLowerCase().compareTo(
            b.albumOrUnknown.toLowerCase(),
          ),
        );
        break;
      case SongSortType.DURATION:
        sortedList.sort((a, b) => a.duration!.compareTo(b.duration!));
        break;
      case SongSortType.SIZE:
        sortedList.sort((a, b) => a.size!.compareTo(b.size!));
        break;
      case SongSortType.DISPLAY_NAME:
        break;
    }

    if (orderType == OrderType.DESC_OR_GREATER) {
      sortedList = sortedList.reversed.toList();
    }

    return sortedList;
  }
}
