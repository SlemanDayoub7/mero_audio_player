import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';

class SliderProgress extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;
  final EdgeInsetsGeometry? padding;
  final double? trackHeight;
  final double? enabledThumbRadius;
  const SliderProgress({
    Key? key,
    required this.position,
    required this.duration,
    required this.onSeek,
    this.padding = EdgeInsets.zero,
    this.trackHeight,
    this.enabledThumbRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxSeconds = duration.inSeconds.toDouble();
    final valueSeconds =
        position.inSeconds.clamp(0, duration.inSeconds).toDouble();

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        valueIndicatorTextStyle: TextStyles.bodyMedium,
        trackHeight: trackHeight ?? 4.h,
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: enabledThumbRadius ?? 7.r,
        ),
      ),
      child: Slider(
        padding: padding,
        value: valueSeconds,

        max: maxSeconds > 0 ? maxSeconds : 1,
        activeColor: Colors.white,
        inactiveColor: Colors.grey.withOpacity(0.5),
        onChanged: (v) => onSeek(Duration(seconds: v.toInt())),
      ),
    );
  }
}
