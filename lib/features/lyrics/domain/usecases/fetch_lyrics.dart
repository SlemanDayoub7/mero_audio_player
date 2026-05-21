import 'package:dartz/dartz.dart';
import 'package:mero_audio_player/core/error/failures.dart';

import '../entities/lyrics.dart';
import '../repositories/lyrics_repository.dart';

/// Use case for fetching lyrics for a song
class FetchLyrics {
  final LyricsRepository repository;

  FetchLyrics(this.repository);

  /// Fetch lyrics with fallback strategy:
  /// 1. Check cache first
  /// 2. Fetch from local file
  /// 3. Fetch from remote API
  Future<Either<Failure, Lyrics?>> call({
    required String title,
    required String artist,
    required Duration duration,
  }) async {
    try {
      // Try to get cached lyrics first
      final cachedLyrics = await repository.getCachedLyrics(
        title: title,
        artist: artist,
      );
      if (cachedLyrics != null) {
        return Right(cachedLyrics);
      }

      // Try to get from local file
      final localLyrics = await repository.fetchLocalLyrics(
        title: title,
        artist: artist,
      );
      if (localLyrics != null) {
        await repository.cacheLyrics(localLyrics);
        return Right(localLyrics);
      }

      // Try to fetch from remote
      final remoteLyrics = await repository.fetchLyrics(
        title: title,
        artist: artist,
        duration: duration,
      );
      if (remoteLyrics != null) {
        await repository.cacheLyrics(remoteLyrics);
        return Right(remoteLyrics);
      }

      return const Right(null);
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }
}
