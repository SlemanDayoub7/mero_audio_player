import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/cubit/audio/audio_cubit.dart';
import 'package:mero_audio_player/features/audio_player/presentation/cubit/audio_player/audio_player_cubit.dart';
import 'package:mero_audio_player/features/audio_player/presentation/cubit/audio/audio_state.dart';
import 'package:mero_audio_player/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // إعداد الأنميشن للصورة
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    _fetchAudiosAndNavigate();
  }

  Future<void> _fetchAudiosAndNavigate() async {
    final audioCubit = context.read<AudioCubit>();
    audioCubit.fetchAudios();

    final audioState = await audioCubit.stream.firstWhere(
      (state) => state is AudioLoaded || state is AudioError,
    );

    if (audioState is AudioLoaded) {
      context.read<AudioPlayerCubit>().loadPlaylist(
        audioState.audios,
        autoRun: false,
      );
    }

    await Future.delayed(const Duration(seconds: 5));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/images/mero.jpg",
                width: 200.w,
                height: 200.w,
              ),
              SizedBox(height: 20.h),

              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 32.sp,
                  fontFamily: "Changa",
                  color: Colors.black,
                ),
                child: AnimatedTextKit(
                  animatedTexts: [WavyAnimatedText('Mero Audio Player')],
                  isRepeatingAnimation: true,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
