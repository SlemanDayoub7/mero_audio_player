// domain/entities/audiobook.dart
import 'package:hive/hive.dart';
import 'audio_file.dart';

part 'audiobook.g.dart';

@HiveType(typeId: 2) // عدّل typeId إن كان متعارضًا في مشروعك
class Audiobook extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final AudioFile file;

  @HiveField(2)
  final List<Chapter> chapters;

  Audiobook({required this.id, required this.file, required this.chapters});
}

@HiveType(typeId: 3)
class Chapter extends HiveObject {
  @HiveField(0)
  final String title;

  /// نخزن بالـ milliseconds لأن Hive لا يخزن Duration تلقائيًا
  @HiveField(1)
  final int startMs;

  @HiveField(2)
  final int endMs;

  Chapter({required this.title, required this.startMs, required this.endMs});

  Duration get start => Duration(milliseconds: startMs);
  Duration get end => Duration(milliseconds: endMs);
}
