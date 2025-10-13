import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/features/settings/presentation/pages/change_background/change_background_page.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';

class ControlIconWidget extends StatelessWidget {
  final IconData? icon;
  final double? size;
  final SvgGenImage? svgGenImage;
  final Color? color;
  final Function()? onPressed;
  final double? opacity;
  final bool? rotate;
  final Color? borderColor;
  const ControlIconWidget({
    super.key,
    this.svgGenImage,
    this.icon,
    this.size,
    this.onPressed,
    this.opacity,
    this.color,
    this.rotate = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      splashColor: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(100.r),
      child: RotatedBox(
        quarterTurns: rotate! ? 2 : 0,
        child: Container(
          padding: EdgeInsets.all(6.w),
          width: (size ?? 45.w),
          height: (size ?? 45.w),
          decoration: BoxDecoration(
            border:
                borderColor != null ? Border.all(color: borderColor!) : null,
            shape: BoxShape.circle,
            color: (globalBackgroundColor ?? Colors.black).withOpacity(
              opacity ?? 0.5,
            ),
          ),
          child:
              svgGenImage != null
                  ? svgGenImage!.svg(
                    color: color ?? Colors.white,
                    width: (size ?? 45.w),
                    height: (size ?? 45.w),
                  )
                  : Icon(
                    icon,
                    size: size ?? 40.sp,
                    color: color ?? Colors.white,
                  ),
        ),
      ),
    );
  }
}
