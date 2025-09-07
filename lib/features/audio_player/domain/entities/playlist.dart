import 'package:hive/hive.dart';
import 'audio_file.dart';

part 'playlist.g.dart';

@HiveType(typeId: 1)
class Playlist extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<AudioFile> audios;

  Playlist({required this.name, required this.audios});
}
