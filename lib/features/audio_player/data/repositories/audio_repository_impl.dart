import 'package:mero_audio_player/injection.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../domain/entities/audio_file.dart';
import '../../domain/repositories/audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  // Folders you want to exclude (no trailing slash, lower-case for consistency)
  final List<String> _excludedFolders = [
    '/whatsapp/media/whatsapp audio',
    '/download',
    '/music/ringtones',
  ];

  // Helper to check if path belongs to excluded folder
  bool _isExcluded(String? path) {
    if (path == null) return false;
    final lowerPath = path.toLowerCase();
    return _excludedFolders.any((excluded) => lowerPath.contains(excluded));
  }

  @override
  Future<List<AudioFile>> fetchAudioFiles() async {
    bool perm = await _audioQuery.permissionsStatus();
    if (!perm) {
      perm = await _audioQuery.permissionsRequest();
      if (!perm) throw Exception('Permission denied');
    }

    var songs = await _audioQuery.querySongs(
      sortType: selectedSort,
      orderType: orderType,
      uriType: UriType.EXTERNAL,
    );

    final filteredSongs =
        songs
            .where(
              (song) => song.fileExtension != 'opus' && !_isExcluded(song.data),
            )
            .toList();

    return filteredSongs.map((song) => AudioFile.fromSongModel(song)).toList();
  }

  @override
  Future<List<ArtistModel>> fetchArtists() async {
    bool perm = await _audioQuery.permissionsStatus();
    if (!perm) {
      perm = await _audioQuery.permissionsRequest();
      if (!perm) throw Exception('Permission denied');
    }

    List<ArtistModel> artists = await _audioQuery.queryArtists(
      sortType: ArtistSortType.ARTIST,
      orderType: OrderType.ASC_OR_SMALLER,
    );
    artists.removeWhere((artist) => artist.artist == "<unknown>");
    return artists;
  }

  @override
  Future<List<AlbumModel>> fetchAlbums() async {
    bool perm = await _audioQuery.permissionsStatus();
    if (!perm) {
      perm = await _audioQuery.permissionsRequest();
      if (!perm) throw Exception('Permission denied');
    }

    final albums = await _audioQuery.queryAlbums(
      sortType: AlbumSortType.ALBUM,
      orderType: OrderType.ASC_OR_SMALLER,
    );

    return albums;
  }

  @override
  Future<List<AudioFile>> fetchSongsByArtist(String artistName) async {
    bool perm = await _audioQuery.permissionsStatus();
    if (!perm) {
      perm = await _audioQuery.permissionsRequest();
      if (!perm) throw Exception('Permission denied');
    }

    var songs = await _audioQuery.queryAudiosFrom(
      AudiosFromType.ARTIST,
      artistName,
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
    );

    final filteredSongs =
        songs
            .where(
              (song) => song.fileExtension != 'opus' && !_isExcluded(song.data),
            )
            .toList();

    return filteredSongs.map((song) => AudioFile.fromSongModel(song)).toList();
  }

  @override
  Future<List<AudioFile>> fetchSongsByAlbum(String albumName) async {
    bool perm = await _audioQuery.permissionsStatus();
    if (!perm) {
      perm = await _audioQuery.permissionsRequest();
      if (!perm) throw Exception('Permission denied');
    }

    var songs = await _audioQuery.queryAudiosFrom(
      AudiosFromType.ALBUM,
      albumName,
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
    );

    final filteredSongs =
        songs
            .where(
              (song) => song.fileExtension != 'opus' && !_isExcluded(song.data),
            )
            .toList();

    return filteredSongs.map((song) => AudioFile.fromSongModel(song)).toList();
  }
}
