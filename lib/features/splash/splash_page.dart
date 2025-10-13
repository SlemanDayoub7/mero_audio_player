import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_circular_progress_indicator.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';
import 'package:mero_audio_player/core/di/injection.dart';
import 'package:mero_audio_player/main_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await Injection.init();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Color(0xFFF5EFE2)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Assets.images.logo.image(width: 0.9.sw, height: 0.9.sw),
                Text(
                  'Mero Audio Player',
                  style: TextStyles.displayLarge.copyWith(color: Colors.black),
                ),
                SizedBox(height: 10.h),
                AppCircularProgressIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
