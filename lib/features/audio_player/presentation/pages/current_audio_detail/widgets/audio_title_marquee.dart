import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marquee/marquee.dart';
import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';

class AudioTitleMarquee extends StatelessWidget {
  final String audioTitle;

  const AudioTitleMarquee({Key? key, required this.audioTitle})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,

      child: Marquee(
        text: audioTitle,
        style: TextStyles.displayLarge.copyWith(color: Colors.white),
        scrollAxis: Axis.horizontal,
        blankSpace: 200.w,

        velocity: 50,
        startPadding: 50.w,

        accelerationDuration: const Duration(milliseconds: 500),
        accelerationCurve: Curves.linear,
        decelerationDuration: const Duration(milliseconds: 500),
        decelerationCurve: Curves.linear,
        pauseAfterRound: const Duration(milliseconds: 500),
      ),
    );
  }
}
