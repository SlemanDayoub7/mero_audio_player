// import 'dart:developer';
// import 'dart:async';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_kit.dart';

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
// import 'package:mero_audio_player/features/audio_player/domain/entities/chapter.dart';
// import 'package:mero_audio_player/features/audio_player/domain/entities/playlist.dart';
// import 'create_audio_book_event.dart';
// import 'create_audio_book_state.dart';

// class CreateAudiobookBloc
//     extends Bloc<CreateAudiobookEvent, CreateAudiobookState> {
//   final AudioPlayer _player = AudioPlayer();
//   StreamSubscription? _positionSub;
//   AudioPlayer get player => _player;
//   CreateAudiobookBloc(AudioFile file)
//     : super(CreateAudiobookState.initial(file)) {
//     on<NameChanged>((e, emit) => emit(state.copyWith(bookName: e.name)));
//     on<ChapterNameChanged>(
//       (e, emit) => emit(state.copyWith(chapterName: e.name)),
//     );
//     on<RangeChanged>(
//       (e, emit) => emit(state.copyWith(startMs: e.startMs, endMs: e.endMs)),
//     );
//     on<AddChapter>(_onAddChapter);
//     on<PlayRange>(_onPlayRange);
//     on<PlayChapter>(_onPlayChapter);
//     on<StopAudio>(_onStopAudio);
//     on<SaveAudiobook>(_onSaveAudiobook);
//     on<UndoChapter>(_onUndoChapter);
//     on<UpdateProgress>((e, emit) => emit(state.copyWith(progress: e.position)));

//     // Listener واحد فقط لتحديث التقدم
//     _positionSub = _player.onPositionChanged.listen((pos) {
//       add(UpdateProgress(pos));
//       if (state.isPlaying && pos.inMilliseconds > state.currentEndMs) {
//         _player.pause();
//         _player.seek(Duration(milliseconds: state.startMs.toInt()));
//       }
//     });
//   }

//   Future<void> _onAddChapter(
//     AddChapter event,
//     Emitter<CreateAudiobookState> emit,
//   ) async {
//     if (state.chapterName.isEmpty || state.startMs >= state.endMs) return;
//     final ch = Chapter(
//       title: state.chapterName,
//       startMs: state.startMs.toInt(),
//       endMs: state.endMs.toInt(),
//     );
//     emit(
//       state.copyWith(
//         chapters: [...state.chapters, ch],
//         chapterName: '',
//         startMs: state.endMs,
//         endMs: state.audioFile.duration?.toDouble() ?? 0,
//         history: [...state.history, state.chapters], // حفظ للتراجع
//       ),
//     );
//   }

//   Future<void> _onUndoChapter(
//     UndoChapter event,
//     Emitter<CreateAudiobookState> emit,
//   ) async {
//     if (state.history.isEmpty) return;
//     final previous = state.history.last;
//     emit(
//       state.copyWith(chapters: previous, history: state.history..removeLast()),
//     );
//   }

//   Future<void> _onPlayRange(
//     PlayRange event,
//     Emitter<CreateAudiobookState> emit,
//   ) async {
//     emit(state.copyWith(isPlaying: true, currentEndMs: state.endMs.toInt()));
//     _player.seek(Duration(milliseconds: state.startMs.toInt()));
//     if (_player.state == PlayerState.stopped) {
//       await _player.play(
//         DeviceFileSource(state.audioFile.uri!),
//         position: Duration(milliseconds: state.startMs.toInt()),
//       );
//     } else if (_player.state == PlayerState.paused) {
//       await _player.resume();
//     }
//   }

//   Future<void> _onPlayChapter(
//     PlayChapter event,
//     Emitter<CreateAudiobookState> emit,
//   ) async {
//     await _player.stop();
//     emit(state.copyWith(isPlaying: true, currentEndMs: event.chapter.endMs));
//     await _player.play(
//       DeviceFileSource(state.audioFile.uri!),
//       position: Duration(milliseconds: event.chapter.startMs),
//     );
//   }

//   Future<void> _onStopAudio(
//     StopAudio event,
//     Emitter<CreateAudiobookState> emit,
//   ) async {
//     await _player.stop();
//     emit(state.copyWith(isPlaying: false));
//   }

//   Future<void> _onSaveAudiobook(
//     SaveAudiobook event,
//     Emitter<CreateAudiobookState> emit,
//   ) async {
//     if (state.bookName.isEmpty || state.chapters.isEmpty) return;
//     emit(state.copyWith(isSaving: true));

//     final List<AudioFile> chapterFiles = [];
//     for (var ch in state.chapters) {
//       final path = await _cutAudioFile(ch);
//       if (path != null) {
//         chapterFiles.add(
//           AudioFile(
//             id: ch.hashCode,
//             title: ch.title,
//             uri: path,
//             duration: ch.endMs - ch.startMs,
//           ),
//         );
//       }
//     }

//     final playlist = Playlist(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       name: state.bookName,
//       audios: chapterFiles,
//       isAudiobook: true,
//       chapters: state.chapters,
//     );

//     emit(state.copyWith(isSaving: false, playlist: playlist));
//   }

//   Future<String?> _cutAudioFile(Chapter ch) async {
//     try {
//       final dir = await getApplicationDocumentsDirectory();
//       String baseName = "${ch.title}_${DateTime.now().millisecondsSinceEpoch}";
//       String ext = state.audioFile.uri!.split('.').last.toLowerCase();

//       String codec =
//           ext == 'mp3' ? 'libmp3lame' : (ext == 'flac' ? 'flac' : 'aac');
//       String outExt = ext == 'mp3' ? 'mp3' : (ext == 'flac' ? 'flac' : 'm4a');
//       String outPath = "${dir.path}/$baseName.$outExt";

//       String command =
//           '-i "${state.audioFile.uri}" -ss ${ch.startMs / 1000} -to ${ch.endMs / 1000} -vn -c:a $codec "$outPath"';
//       final session = await FFmpegKit.execute(command);
//       final returnCode = await session.getReturnCode();
//       if (returnCode != null && returnCode.isValueSuccess()) return outPath;
//       log(await session.getOutput() ?? '');
//       return null;
//     } catch (e) {
//       log('cutAudioFile error: $e');
//       return null;
//     }
//   }

//   @override
//   Future<void> close() {
//     _positionSub?.cancel();
//     _player.dispose();
//     return super.close();
//   }
// }
