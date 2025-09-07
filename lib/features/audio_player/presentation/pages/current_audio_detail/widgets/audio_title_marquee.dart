import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marquee/marquee.dart';

class AudioInfo extends StatelessWidget {
  final String audioTitle;
  final ThemeData theme;

  const AudioInfo({Key? key, required this.audioTitle, required this.theme})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.h,

      child: Marquee(
        text: audioTitle,
        style: theme.textTheme.headlineSmall!.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
        ),
        scrollAxis: Axis.horizontal,
        blankSpace: 200.w,
        velocity: 100.0,
        startPadding: 50.w,

        accelerationDuration: const Duration(milliseconds: 500),
        accelerationCurve: Curves.easeIn,
        decelerationDuration: const Duration(milliseconds: 500),
        decelerationCurve: Curves.easeOut,
        pauseAfterRound: const Duration(milliseconds: 500),
      ),
    );
  }
}
