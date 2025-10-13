import 'package:hive/hive.dart';
import '../../../../music_library/domain/entities/audio_file/audio_file.dart';
import '../chapter/chapter.dart';

part 'playlist.g.dart';

@HiveType(typeId: 1)
class Playlist extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<AudioFile> audios;

  @HiveField(3)
  final bool isAudiobook; // 👈 جديد

  @HiveField(4)
  final List<Chapter>? chapters; // 👈 للفصول (إذا Audiobook)

  Playlist({
    required this.id,
    required this.name,
    required this.audios,
    this.isAudiobook = false,
    this.chapters,
  });
}
