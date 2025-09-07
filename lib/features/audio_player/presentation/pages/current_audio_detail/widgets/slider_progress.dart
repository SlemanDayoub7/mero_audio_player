import 'package:flutter/material.dart';

class SliderProgress extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const SliderProgress({
    Key? key,
    required this.position,
    required this.duration,
    required this.onSeek,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxSeconds = duration.inSeconds.toDouble();
    final valueSeconds =
        position.inSeconds.clamp(0, duration.inSeconds).toDouble();

    final theme = Theme.of(context);

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
      ),
      child: Slider(
        value: valueSeconds,
        max: maxSeconds > 0 ? maxSeconds : 1,
        activeColor: theme.colorScheme.primary,
        inactiveColor: theme.colorScheme.primary.withOpacity(0.3),
        onChanged: (v) => onSeek(Duration(seconds: v.toInt())),
      ),
    );
  }
}
