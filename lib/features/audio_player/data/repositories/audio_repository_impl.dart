import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/artwork.dart';
import 'package:mero_audio_player/injection.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/audio_file.dart';
import '../../domain/repositories/audio_repository.dart';

final demoAudioFiles = <AudioFile>[
  // 🎤 الفنان الأول
  AudioFile(
    id: 1,
    title: "Blue Mirage",
    artist: "Arvonix",
    album: "Shadowsphere",
    duration: 210000,
    size: 3000000,
  ),
  AudioFile(
    id: 2,
    title: "Crystal Haze",
    artist: "Arvonix",
    album: "Shadowsphere",
    duration: 185000,
    size: 2800000,
  ),
  AudioFile(
    id: 3,
    title: "Silent Nova",
    artist: "Arvonix",
    album: "Echo Nexus",
    duration: 200000,
    size: 3100000,
  ),
  AudioFile(
    id: 4,
    title: "Velora Dreams",
    artist: "Arvonix",
    album: "Echo Nexus",
    duration: 220000,
    size: 3200000,
  ),
  AudioFile(
    id: 5,
    title: "Phantom Dawn",
    artist: "Arvonix",
    album: "Echo Nexus",
    duration: 240000,
    size: 3300000,
  ),

  // 🎤 الفنان الثاني
  AudioFile(
    id: 6,
    title: "Iron Skies",
    artist: "Zerath",
    album: "Pulse Machine",
    duration: 190000,
    size: 2900000,
  ),
  AudioFile(
    id: 7,
    title: "Neon Serpent",
    artist: "Zerath",
    album: "Pulse Machine",
    duration: 200000,
    size: 3000000,
  ),
  AudioFile(
    id: 8,
    title: "Digital Phantom",
    artist: "Zerath",
    album: "Spectra Flow",
    duration: 210000,
    size: 3100000,
  ),
  AudioFile(
    id: 9,
    title: "Circuit Flame",
    artist: "Zerath",
    album: "Spectra Flow",
    duration: 230000,
    size: 3300000,
  ),
  AudioFile(
    id: 10,
    title: "Omega Shift",
    artist: "Zerath",
    album: "Spectra Flow",
    duration: 180000,
    size: 2800000,
  ),

  // 🎤 الفنان الثالث
  AudioFile(
    id: 11,
    title: "Whisper Core",
    artist: "Nythera",
    album: "Frozen Veins",
    duration: 250000,
    size: 3500000,
  ),
  AudioFile(
    id: 12,
    title: "Glacier Sparks",
    artist: "Nythera",
    album: "Frozen Veins",
    duration: 220000,
    size: 3200000,
  ),
  AudioFile(
    id: 13,
    title: "Twilight Bloom",
    artist: "Nythera",
    album: "Lunar Ashes",
    duration: 200000,
    size: 3000000,
  ),
  AudioFile(
    id: 14,
    title: "Ashen Vortex",
    artist: "Nythera",
    album: "Lunar Ashes",
    duration: 230000,
    size: 3400000,
  ),
  AudioFile(
    id: 15,
    title: "Silver Veil",
    artist: "Nythera",
    album: "Lunar Ashes",
    duration: 240000,
    size: 3500000,
  ),

  // 🎤 الفنان الرابع
  AudioFile(
    id: 16,
    title: "Solar Drift",
    artist: "Kryvon",
    album: "Celestial Run",
    duration: 210000,
    size: 3100000,
  ),
  AudioFile(
    id: 17,
    title: "Echo Storm",
    artist: "Kryvon",
    album: "Celestial Run",
    duration: 190000,
    size: 2900000,
  ),
  AudioFile(
    id: 18,
    title: "Aether Waves",
    artist: "Kryvon",
    album: "Nebula Void",
    duration: 200000,
    size: 3000000,
  ),
  AudioFile(
    id: 19,
    title: "Stellar Dust",
    artist: "Kryvon",
    album: "Nebula Void",
    duration: 220000,
    size: 3200000,
  ),
  AudioFile(
    id: 20,
    title: "Gravity Pulse",
    artist: "Kryvon",
    album: "Nebula Void",
    duration: 230000,
    size: 3300000,
  ),
];

bool firstRun = true;
List<AudioFile> artworks = [];
String placeArtwork = '';

class AudioRepositoryImpl implements AudioRepository {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final Box<Artwork> _box = Hive.box<Artwork>('artworks');

  // Folders you want to exclude (no trailing slash, lower-case for consistency)
  final List<String> _excludedFolders = [];

  // Helper to check if path belongs to excluded folder
  bool _isExcluded(String? path) {
    if (path == null) return false;
    final lowerPath = path.toLowerCase();
    return _excludedFolders.any((excluded) => lowerPath.contains(excluded));
  }

  /// Cache artwork to file and return file path
  ///
  Future<String?> _cacheArtwork(int audioId) async {
    try {
      final Uint8List? artworkBytes = await _audioQuery.queryArtwork(
        audioId,
        ArtworkType.AUDIO,
        format: ArtworkFormat.JPEG,
        size: 400,
        quality: 90,
      );

      if (artworkBytes == null || artworkBytes.isEmpty) {
        return null;
      }

      final tempDir = await getTemporaryDirectory();
      final artworkDir = Directory('${tempDir.path}/artworks');

      if (!await artworkDir.exists()) {
        await artworkDir.create(recursive: true);
      }

      final artworkFile = File('${artworkDir.path}/artwork_$audioId.jpg');
      await artworkFile.writeAsBytes(artworkBytes);

      return artworkFile.path;
    } catch (e) {
      return null;
    }
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
          final artworkPath = await _cacheArtwork(song.id);
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
