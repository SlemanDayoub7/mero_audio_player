import '../entities/lyrics.dart';

/// Abstract repository for lyrics operations
abstract class LyricsRepository {
  /// Fetch lyrics for a song
  /// Returns null if lyrics are not found
  Future<Lyrics?> fetchLyrics({
    required String title,
    required String artist,
    required Duration duration,
  });

  /// Fetch lyrics from local file if exists
  Future<Lyrics?> fetchLocalLyrics({
    required String title,
    required String artist,
  });

  /// Cache lyrics locally
  Future<void> cacheLyrics(Lyrics lyrics);

  /// Get cached lyrics
  Future<Lyrics?> getCachedLyrics({
    required String title,
    required String artist,
  });

  /// Clear all cached lyrics
  Future<void> clearCache();

  /// Delete specific cached lyrics
  Future<void> deleteCachedLyrics({
    required String title,
    required String artist,
  });
}
