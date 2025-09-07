import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:mero_audio_player/core/constants/app_constants.dart';
import 'package:mero_audio_player/core/themes/dark_theme.dart';
import 'package:mero_audio_player/core/themes/light_theme.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/playlist.dart';
import 'package:mero_audio_player/features/audio_player/presentation/cubit/audio/audio_cubit.dart';
import 'package:mero_audio_player/features/audio_player/presentation/cubit/audio_player/audio_player_cubit.dart';
import 'package:mero_audio_player/features/audio_player/presentation/cubit/playlist/playlist_cubit.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/splash/splash_screen.dart';
import 'package:mero_audio_player/core/app_startup.dart';
import 'package:mero_audio_player/features/audio_player/services/audio_handler.dart';
import 'package:mero_audio_player/injection.dart' as di;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => di.getIt<AudioCubit>()),
            BlocProvider(
              create:
                  (_) => AudioPlayerCubit(audioHandler as AudioPlayerHandler),
            ),
            BlocProvider(
              create:
                  (_) => PlaylistCubit(
                    Hive.box<Playlist>(AppConstants.playlistBoxName),
                  ),
            ),
          ],
          child: AnimatedBuilder(
            animation: _themeProvider,
            builder: (context, _) {
              return MaterialApp(
                title: AppConstants.appTitle,
                debugShowCheckedModeBanner: false,
                theme: LightTheme.theme,

                themeMode: _themeProvider.themeMode,
                home: const SplashScreen(),
              );
            },
          ),
        );
      },
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }
}
