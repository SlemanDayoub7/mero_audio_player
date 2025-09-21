import 'package:hive/hive.dart';

part 'chapter.g.dart';

@HiveType(typeId: 2)
class Chapter {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final int startMs;

  @HiveField(2)
  final int endMs;

  Chapter({required this.title, required this.startMs, required this.endMs});

  Duration get start => Duration(milliseconds: startMs);
  Duration get end => Duration(milliseconds: endMs);
}
