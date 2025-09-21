import 'package:flutter/services.dart';

class MediaStoreService {
  static const _channel = MethodChannel('media_store');

  static Future<bool> deleteAudio(String uri) async {
    try {
      final result = await _channel.invokeMethod<bool>('deleteAudio', {
        'uri': uri,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}
