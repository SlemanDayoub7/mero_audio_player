import 'package:hive/hive.dart';

part 'artwork.g.dart';

@HiveType(typeId: 3)
class Artwork extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String? artworkFilePath; // NEW: Path to cached artwork file

  Artwork({
    required this.id,
    this.artworkFilePath, // NEW
  });
}
