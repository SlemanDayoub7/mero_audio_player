// import 'package:flutter/services.dart';

// class NativeAudioTrimmer {
//   static const platform = MethodChannel(
//     'com.example.mero_audio_player/audio_trimmer',
//   );

//   static Future<String?> trimAudio(
//     String inputPath,
//     int startMs,
//     int endMs,
//   ) async {
//     try {
//       final String? outputPath = await platform.invokeMethod('trimAudio', {
//         'inputPath': inputPath,
//         'startMs': startMs,
//         'endMs': endMs,
//       });
//       return outputPath;
//     } on PlatformException catch (e) {
//       print("Failed to trim audio: '${e.message}'.");
//       return null;
//     }
//   }
// }

// // // Usage in your existing code:
// // try {
// //   // First trim the audio
// //   final String? trimmedPath = await NativeAudioTrimmer.trimAudio(
// //     audio.data ?? '',
// //     10000, // start at 10 seconds
// //     30000  // end at 30 seconds
// //   );
  
// //   if (trimmedPath != null) {
// //     // Then set as ringtone
// //     success = await RingtoneSet.setRingtoneFromFile(File(trimmedPath));
// //   } else {
// //     success = false;
// //   }
// // } on PlatformException {
// //   success = false;
// // }