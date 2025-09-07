import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mero_audio_player/features/audio_player/data/repositories/audio_repository_impl.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/domain/repositories/audio_repository.dart';
import 'package:mero_audio_player/features/audio_player/presentation/cubit/audio/audio_cubit.dart';
import 'package:mero_audio_player/features/audio_player/presentation/cubit/audio_player/audio_player_cubit.dart';

final getIt = GetIt.instance;

void setupInjection() {
  // Register repository as a lazy singleton
  getIt.registerLazySingleton<AudioRepository>(() => AudioRepositoryImpl());

  // Register Cubit factory (new instance on each call)
  getIt.registerFactory(() => AudioCubit(getIt<AudioRepository>()));
}
