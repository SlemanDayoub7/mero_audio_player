import 'package:dio/dio.dart';

import '../models/lyrics_model.dart';
import '../../domain/entities/lyric_line.dart';
import '../models/lyric_line_model.dart';

/// Remote data source for fetching lyrics from APIs
abstract class LyricsRemoteDatasource {
  Future<LyricsModel?> fetchLyrics({
    required String title,
    required String artist,
    required Duration duration,
  });
}

class LyricsRemoteDatasourceImpl implements LyricsRemoteDatasource {
  final Dio dio;

  LyricsRemoteDatasourceImpl(this.dio);

  // Using lyrics.ovh API (free, no auth required, CORS enabled)
  static const String _baseUrl = 'https://lyrics.ovh/v1';

  @override
  Future<LyricsModel?> fetchLyrics({
    required String title,
    required String artist,
    required Duration duration,
  }) async {
    try {
      final response = await dio.get(
        '$_baseUrl/$artist/$title',
        options: Options(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final lyricsText = response.data['lyrics'] as String?;
        if (lyricsText != null && lyricsText.isNotEmpty) {
          // Parse plain text lyrics
          final lines = lyricsText
              .split('\n')
              .where((line) => line.isNotEmpty)
              .map((line) => LyricLineModel(
                    text: line,
                    timestamp: null,
                  ))
              .toList();

          return LyricsModel(
            title: title,
            artist: artist,
            duration: duration,
            lines: lines,
            isSynced: false,
            source: 'lyrics.ovh',
          );
        }
      }
      return null;
    } on DioException {
      return null;
    } catch (e) {
      return null;
    }
  }
}
