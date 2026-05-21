import '../../domain/entities/lyrics.dart';
import '../../domain/repositories/lyrics_repository.dart';
import '../datasources/lyrics_local_datasource.dart';
import '../datasources/lyrics_remote_datasource.dart';
import '../models/lyrics_model.dart';

/// Implementation of LyricsRepository
class LyricsRepositoryImpl implements LyricsRepository {
  final LyricsLocalDatasource localDatasource;
  final LyricsRemoteDatasource remoteDatasource;

  LyricsRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
  });

  /// Generate cache key
  String _generateKey(String title, String artist) {
    return '${title}_${artist}'.toLowerCase().replaceAll(' ', '_');
  }

  @override
  Future<Lyrics?> fetchLyrics({
    required String title,
    required String artist,
    required Duration duration,
  }) async {
    return await remoteDatasource.fetchLyrics(
      title: title,
      artist: artist,
      duration: duration,
    );
  }

  @override
  Future<Lyrics?> fetchLocalLyrics({
    required String title,
    required String artist,
  }) async {
    // This could be extended to read .lrc files from local storage
    // For now, we'll skip this implementation
    return null;
  }

  @override
  Future<void> cacheLyrics(Lyrics lyrics) async {
    final key = _generateKey(lyrics.title, lyrics.artist);
    final model = LyricsModel.fromEntity(lyrics);
    await localDatasource.cacheLyrics(key, model);
  }

  @override
  Future<Lyrics?> getCachedLyrics({
    required String title,
    required String artist,
  }) async {
    final key = _generateKey(title, artist);
    return await localDatasource.getLyrics(key);
  }

  @override
  Future<void> clearCache() async {
    await localDatasource.clearAll();
  }

  @override
  Future<void> deleteCachedLyrics({
    required String title,
    required String artist,
  }) async {
    final key = _generateKey(title, artist);
    await localDatasource.deleteLyrics(key);
  }
}
