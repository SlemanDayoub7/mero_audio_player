import 'package:hive/hive.dart';
import '../../domain/entities/audiobook.dart';
import '../../domain/repositories/audiobook_repository.dart';

class AudiobookRepositoryImpl implements AudiobookRepository {
  final Box<Audiobook> box;

  AudiobookRepositoryImpl(this.box);

  @override
  Future<List<Audiobook>> getAllAudiobooks() async {
    return box.values.toList();
  }

  @override
  Future<void> saveAudiobook(Audiobook audiobook) async {
    await box.put(audiobook.id, audiobook);
  }

  @override
  Future<void> deleteAudiobook(String id) async {
    await box.delete(id);
  }
}
