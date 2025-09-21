// import 'package:flutter/material.dart';
// import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
// import 'package:mero_audio_player/core/themes/text_styles.dart';
// import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
// import 'package:mero_audio_player/features/audio_player/domain/entities/chapter.dart';
// import 'package:mero_audio_player/features/audio_player/domain/entities/playlist.dart';
// import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
// import 'package:path_provider/path_provider.dart';

// class CreateAudiobookPage extends StatefulWidget {
//   final AudioFile audioFile;
//   const CreateAudiobookPage({super.key, required this.audioFile});

//   @override
//   State<CreateAudiobookPage> createState() => _CreateAudiobookPageState();
// }

// class _CreateAudiobookPageState extends State<CreateAudiobookPage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _chapterNameController = TextEditingController();
//   final List<Chapter> _chapters = [];

//   double _startMs = 0;
//   double _endMs = 0;
//   bool _isSaving = false;

//   @override
//   void initState() {
//     super.initState();
//     _endMs = widget.audioFile.duration?.toDouble() ?? 0;
//   }

//   String _formatMs(double ms) {
//     final d = Duration(milliseconds: ms.toInt());
//     final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
//     final hh = d.inHours;
//     return hh > 0 ? "$hh:$mm:$ss" : "$mm:$ss";
//   }

//   void _addChapter() {
//     if (_chapterNameController.text.isEmpty || _startMs >= _endMs) return;

//     final ch = Chapter(
//       title: _chapterNameController.text,
//       startMs: _startMs.toInt(),
//       endMs: _endMs.toInt(),
//     );

//     setState(() {
//       _chapters.add(ch);
//       _chapterNameController.clear();
//       _startMs = _endMs;
//       _endMs = widget.audioFile.duration?.toDouble() ?? 0;
//     });
//   }

//   Future<String?> _cutAudioFile(Chapter ch) async {
//     try {
//       final dir = await getApplicationDocumentsDirectory();

//       // Detect input extension
//       String ext = widget.audioFile.uri!.split('.').last.toLowerCase();

//       // Prepare a working file path (this will be input to the cutting command)
//       String workingInput = widget.audioFile.uri!;

//       // If FLAC, convert to MP3 first
//       if (ext == 'flac') {
//         String tempMp3Path =
//             "${dir.path}/${ch.title}_${DateTime.now().millisecondsSinceEpoch}_converted.mp3";

//         String convertCmd = '-i "$workingInput" -c:a libmp3lame "$tempMp3Path"';
//         final convSession = await FFmpegKit.execute(convertCmd);
//         final convCode = await convSession.getReturnCode();

//         if (convCode == null || !convCode.isValueSuccess()) {
//           final out = await convSession.getOutput();
//           final stack = await convSession.getFailStackTrace();
//           debugPrint('FFmpeg FLAC→MP3 conversion failed!\n$out\n$stack');
//           return null;
//         }

//         // Use converted MP3 as input for the cut
//         workingInput = tempMp3Path;
//         ext = 'mp3';
//       }

//       // Decide codec for cutting (based on workingInput)
//       String codec;
//       String outExt = ext;
//       switch (ext) {
//         case 'mp3':
//           codec = 'libmp3lame';
//           break;
//         case 'm4a':
//         case 'aac':
//           codec = 'aac';
//           break;
//         default:
//           codec = 'aac';
//           outExt = 'm4a';
//       }

//       // Output file
//       String fileName =
//           "${ch.title}_${DateTime.now().millisecondsSinceEpoch}.$outExt";

//       String cutCmd =
//           '-i "$workingInput" -vn -ss ${ch.startMs / 1000} -to ${ch.endMs / 1000} -c:a $codec "${dir.path}/$fileName"';

//       final session = await FFmpegKit.execute(cutCmd);
//       final returnCode = await session.getReturnCode();

//       if (returnCode != null && returnCode.isValueSuccess()) {
//         return "${dir.path}/$fileName";
//       } else {
//         final output = await session.getOutput();
//         final failStack = await session.getFailStackTrace();
//         debugPrint('FFmpeg cut failed!\n$output\n$failStack');
//         return null;
//       }
//     } catch (e) {
//       debugPrint('Exception cutting audio: $e');
//       return null;
//     }
//   }

//   Future<void> _saveAudiobook() async {
//     if (_nameController.text.isEmpty || _chapters.isEmpty) return;

//     setState(() => _isSaving = true);

//     final List<AudioFile> chapterFiles = [];

//     // for (var ch in _chapters) {
//     //   final path = await _cutAudioFile(ch);
//     //   if (path != null) {
//     //     chapterFiles.add(
//     //       AudioFile(
//     //         id: ch.hashCode,
//     //         title: ch.title,
//     //         uri: path,
//     //         duration: ch.endMs - ch.startMs,
//     //       ),
//     //     );
//     //   }
//     // }

//     // final audiobook = Playlist(
//     //   id: DateTime.now().millisecondsSinceEpoch.toString(),
//     //   name: _nameController.text,
//     //   audios: chapterFiles,
//     //   isAudiobook: true,
//     //   chapters: _chapters,
//     // );

//     // setState(() => _isSaving = false);
//     // Navigator.pop(context, audiobook);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("إنشاء كتاب صوتي", style: TextStyles.displayLarge),
//       ),
//       body:
//           _isSaving
//               ? const Center(child: CircularProgressIndicator())
//               : ListView(
//                 padding: context.paddingHigh,
//                 shrinkWrap: true,
//                 children: [
//                   TextField(
//                     controller: _nameController,
//                     style: TextStyles.headlineLarge,
//                     decoration: InputDecoration(
//                       labelText: "اسم الكتاب",
//                       labelStyle: TextStyles.labelLarge,
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   context.emptySizedHeightHigh,
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       TextField(
//                         style: TextStyles.headlineLarge,
//                         controller: _chapterNameController,
//                         decoration: InputDecoration(
//                           labelText: "اسم الفصل",
//                           labelStyle: TextStyles.labelLarge,
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       context.emptySizedHeightHigh,
//                       Text(
//                         "حدد البداية والنهاية: ${_formatMs(_startMs)} — ${_formatMs(_endMs)}",
//                         style: TextStyles.headlineMedium,
//                       ),
//                       RangeSlider(
//                         min: 0,
//                         max: widget.audioFile.duration?.toDouble() ?? 1,
//                         values: RangeValues(_startMs, _endMs),
//                         onChanged: (values) {
//                           setState(() {
//                             _startMs = values.start;
//                             _endMs = values.end;
//                           });
//                         },
//                       ),
//                       ElevatedButton(
//                         onPressed: _addChapter,
//                         child: Text("حفظ الفصل"),
//                       ),
//                       // ElevatedButton(
//                       //   onPressed: () {
//                       //     context.read<AudioPlayerBloc>().add(
//                       //       PlayAudioRange(
//                       //         audio: widget.audioFile,
//                       //         start: Duration(milliseconds: _startMs.toInt()),
//                       //         end: Duration(milliseconds: _endMs.toInt()),
//                       //       ),
//                       //     );
//                       //   },
//                       //   child: Text("تشغيل"),
//                       // ),
//                     ],
//                   ),
//                   const Divider(),
//                   Expanded(
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       physics: NeverScrollableScrollPhysics(),
//                       itemCount: _chapters.length,
//                       itemBuilder: (context, index) {
//                         final ch = _chapters[index];
//                         return ListTile(
//                           title: Text(ch.title),
//                           subtitle: Text(
//                             "${_formatMs(ch.startMs.toDouble())} — ${_formatMs(ch.endMs.toDouble())}",
//                           ),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: const Icon(Icons.play_arrow),
//                                 tooltip: "تشغيل هذا الفصل",
//                                 onPressed: () {},
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.delete),
//                                 onPressed: () {
//                                   setState(() {
//                                     _chapters.removeAt(index);
//                                   });
//                                 },
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: _saveAudiobook,
//                     child: const Text("حفظ الكتاب الصوتي"),
//                   ),
//                 ],
//               ),
//     );
//   }
// }
