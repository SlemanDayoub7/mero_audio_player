// import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
// import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
// import 'package:mero_audio_player/features/audio_player/domain/entities/playlist.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';

// Future<String> cutAudioFile({
//   required String sourcePath,
//   required String chapterName,
//   required int startMs,
//   required int endMs,
// }) async {
//   final dir = await getApplicationDocumentsDirectory();
//   final outputPath =
//       "${dir.path}/${chapterName}_${DateTime.now().millisecondsSinceEpoch}.mp3";

//   final startSeconds = startMs / 1000.0;
//   final durationSeconds = (endMs - startMs) / 1000.0;

//   final command =
//       '-i "$sourcePath" -ss $startSeconds -t $durationSeconds -c copy "$outputPath"';

//   await FFmpegKit.execute(command);

//   return outputPath;
// }

// Future<List<AudioFile>> createChapterFiles(Playlist audiobook) async {
//   List<AudioFile> files = [];
//   for (var ch in audiobook.chapters!) {
//     final path = await cutAudioFile(
//       sourcePath: audiobook.audios.first.uri!,
//       chapterName: ch.title,
//       startMs: ch.startMs,
//       endMs: ch.endMs,
//     );
//     files.add(
//       AudioFile(
//         id: ch.hashCode,
//         title: ch.title,
//         uri: path,
//         duration: ch.endMs - ch.startMs,
//       ),
//     );
//   }
//   return files;
// }
