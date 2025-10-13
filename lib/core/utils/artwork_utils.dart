import 'dart:io';

import 'package:flutter/services.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';

class ArtworkUtils {
  static Future<String?> loadAssetAsFile(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/mate.png');

      // كتابة محتوى الصورة إلى ملف مؤقت
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> cacheArtwork(
    int audioId,
    OnAudioQuery audioQuery,
  ) async {
    try {
      final Uint8List? artworkBytes = await audioQuery.queryArtwork(
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
}
