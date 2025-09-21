import '../entities/audiobook.dart';

abstract class AudiobookRepository {
  Future<List<Audiobook>> getAllAudiobooks();
  Future<void> saveAudiobook(Audiobook audiobook);
  Future<void> deleteAudiobook(String id);
}
