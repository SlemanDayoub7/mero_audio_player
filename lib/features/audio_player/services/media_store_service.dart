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

class SystemSettings {
  static const platform = MethodChannel(
    'com.example.mero_audio_player/audio_trimmer',
  );

  static Future<void> openWriteSettings() async {
    try {
      await platform.invokeMethod('openWriteSettings');
    } on PlatformException catch (e) {
      print("Failed to open settings: '${e.message}'.");
    }
  }
}
