import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/audio_repository.dart';
import 'audio_state.dart';

class AudioCubit extends Cubit<AudioState> {
  final AudioRepository audioRepository;
  AudioCubit(this.audioRepository) : super(AudioInitial());

  Future<void> fetchAudios() async {
    emit(AudioLoading());
    try {
      final audios = await audioRepository.fetchAudioFiles();
      emit(AudioLoaded(audios));
    } catch (e) {
      emit(AudioError(e.toString()));
    }
  }
}
