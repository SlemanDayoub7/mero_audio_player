import 'package:equatable/equatable.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/chapter.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/playlist.dart';

class CreateAudiobookState extends Equatable {
  final AudioFile audioFile;
  final String bookName;
  final String chapterName;
  final List<Chapter> chapters;
  final List<List<Chapter>> history; // جديد: لتخزين نسخ سابقة للتراجع
  final double startMs;
  final double endMs;
  final bool isSaving;
  final Duration progress;
  final Playlist playlist;
  final bool isPlaying; // جديد: حالة التشغيل
  final int currentEndMs; // جديد: نهاية التشغيل الحالية

  const CreateAudiobookState({
    required this.playlist,
    required this.audioFile,
    required this.bookName,
    required this.chapterName,
    required this.chapters,
    required this.history,
    required this.startMs,
    required this.endMs,
    required this.isSaving,
    required this.progress,
    required this.isPlaying,
    required this.currentEndMs,
  });

  factory CreateAudiobookState.initial(AudioFile file) => CreateAudiobookState(
    playlist: Playlist(id: '', name: '', audios: []),
    audioFile: file,
    bookName: '',
    chapterName: '',
    chapters: [],
    history: [],
    startMs: 0,
    endMs: file.duration?.toDouble() ?? 0,
    isSaving: false,
    progress: Duration.zero,
    isPlaying: false,
    currentEndMs: 0,
  );

  CreateAudiobookState copyWith({
    AudioFile? audioFile,
    String? bookName,
    String? chapterName,
    List<Chapter>? chapters,
    List<List<Chapter>>? history,
    double? startMs,
    double? endMs,
    bool? isSaving,
    Duration? progress,
    Playlist? playlist,
    bool? isPlaying,
    int? currentEndMs,
  }) {
    return CreateAudiobookState(
      audioFile: audioFile ?? this.audioFile,
      bookName: bookName ?? this.bookName,
      chapterName: chapterName ?? this.chapterName,
      chapters: chapters ?? this.chapters,
      history: history ?? this.history,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      isSaving: isSaving ?? this.isSaving,
      progress: progress ?? this.progress,
      playlist: playlist ?? this.playlist,
      isPlaying: isPlaying ?? this.isPlaying,
      currentEndMs: currentEndMs ?? this.currentEndMs,
    );
  }

  @override
  List<Object?> get props => [
    audioFile,
    bookName,
    chapterName,
    chapters,
    history,
    startMs,
    endMs,
    isSaving,
    progress,
    playlist,
    isPlaying,
    currentEndMs,
  ];
}
