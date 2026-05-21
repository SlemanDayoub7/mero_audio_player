import 'package:hive_flutter/hive_flutter.dart';

import '../models/lyrics_model.dart';

/// Local data source for lyrics using Hive
abstract class LyricsLocalDatasource {
  Future<LyricsModel?> getLyrics(String key);
  Future<void> cacheLyrics(String key, LyricsModel lyrics);
  Future<void> deleteLyrics(String key);
  Future<void> clearAll();
}

class LyricsLocalDatasourceImpl implements LyricsLocalDatasource {
  static const boxName = 'lyrics';

  late Box<Map> _lyricsBox;

  /// Initialize the Hive box
  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      _lyricsBox = await Hive.openBox<Map>(boxName);
    } else {
      _lyricsBox = Hive.box<Map>(boxName);
    }
  }

  /// Generate cache key from title and artist
  String _generateKey(String title, String artist) {
    return '${title}_${artist}'.toLowerCase().replaceAll(' ', '_');
  }

  @override
  Future<LyricsModel?> getLyrics(String key) async {
    try {
      await init();
      final data = _lyricsBox.get(key);
      if (data != null) {
        return LyricsModel.fromJson(data.cast<String, dynamic>());
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheLyrics(String key, LyricsModel lyrics) async {
    try {
      await init();
      await _lyricsBox.put(key, lyrics.toJson());
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Future<void> deleteLyrics(String key) async {
    try {
      await init();
      await _lyricsBox.delete(key);
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await init();
      await _lyricsBox.clear();
    } catch (e) {
      // Handle error silently
    }
  }
}
