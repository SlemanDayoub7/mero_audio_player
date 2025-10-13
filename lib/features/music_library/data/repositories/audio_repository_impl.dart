import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:mero_audio_player/core/constants/hive_boxes.dart';

import 'package:mero_audio_player/core/utils/artwork_utils.dart';
import 'package:mero_audio_player/features/music_library/domain/entities/artwork/artwork.dart';
import 'package:mero_audio_player/core/di/injection.dart';
import 'package:mero_audio_player/main.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../domain/entities/audio_file/audio_file.dart';
import '../../domain/repositories/audio_repository.dart';

bool firstRun = true;
List<AudioFile> artworks = [];
String placeArtwork = '';

class AudioRepositoryImpl implements AudioRepository {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final Box<Artwork> _box = Hive.box<Artwork>(HiveBoxes.artworks);

  // Folders you want to exclude (no trailing slash, lower-case for consistency)
  final List<String> _excludedFolders = [];

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
              (song) =>
                  song.duration != 0 &&
                  song.fileExtension != 'opus' &&
                  song.album != 'Ringtones' &&
                  !_isExcluded(song.data),
            )
            .toList();

    final currentIds = filteredSongs.map((s) => s.id).toSet();
    final storedIds = _box.keys.cast<int>().toSet();

    if (firstRun) {
      final toDelete = storedIds.difference(currentIds);
      for (final id in toDelete) {
        final artwork = _box.get(id);
        if (artwork?.artworkFilePath != null) {
          File(artwork!.artworkFilePath!).deleteSync();
        }
        await _box.delete(id);
      }

      for (final song in filteredSongs) {
        if (!_box.containsKey(song.id)) {
          final artworkPath = await ArtworkUtils.cacheArtwork(
            song.id,
            audioQuery,
          );
          await _box.put(
            song.id,
            Artwork(id: song.id, artworkFilePath: artworkPath),
          );
        }
      }

      for (final song in filteredSongs) {
        final art = _box.get(song.id);
        artworks.add(
          AudioFile.fromSongModel(song, artworkPath: art?.artworkFilePath),
        );
      }
    }
    firstRun = false;
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
    final albums = await _audioQuery.queryAlbums(
      sortType: AlbumSortType.ALBUM,
      orderType: orderType,
    );

    List<AlbumModel> validAlbums = [];

    for (final album in albums) {
      final songs = await fetchSongsByAlbum(album.album);
      if (songs.isNotEmpty) {
        AlbumModel albumModel = AlbumModel({
          'album': album.album,
          'numsongs': songs.length,
        });
        validAlbums.add(albumModel);
      }
    }

    return validAlbums;
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

    final List<AudioFile> audioFiles = [];

    for (final song in filteredSongs) {
      if ((song.duration ?? 0) <= 0) {
        continue;
      }
      // final artworkPath = await _cacheArtwork(song.id);
      audioFiles.add(AudioFile.fromSongModel(song));
    }

    return audioFiles;
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

    final List<AudioFile> audioFiles = [];

    for (final song in filteredSongs) {
      if ((song.duration ?? 0) <= 0) {
        continue;
      }
      audioFiles.add(AudioFile.fromSongModel(song));
    }

    return audioFiles;
  }
}
