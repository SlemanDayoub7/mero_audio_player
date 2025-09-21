import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/features/audio_player/presentation/change_background_page.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';

class SpeedDropdown extends StatelessWidget {
  final double currentSpeed;
  final ValueChanged<double> onChanged;

  const SpeedDropdown({
    Key? key,
    required this.currentSpeed,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

    return DropdownButton<double>(
      underline: SizedBox.shrink(),
      dropdownColor: globalBackgroundColor,
      icon: Assets.icons.speed.svg(
        color: Colors.white,
        width: 30.sp,
        height: 30.sp,
      ),
      value: currentSpeed,
      items:
          speeds.map((speed) {
            return DropdownMenuItem<double>(
              value: speed,
              child: Text(
                '${speed}x',
                style: TextStyles.titleMedium.copyWith(color: Colors.white),
              ),
            );
          }).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
