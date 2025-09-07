import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AudioControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const AudioControls({
    Key? key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
  }) : super(key: key);

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color iconColor,
    double size = 40,
  }) {
    return Container(
      width: size.w + 20,
      height: size.w + 20,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: size.sp),
        onPressed: onPressed,
        splashRadius: size / 1.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final primaryColor = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    final secondaryColor = theme.colorScheme.secondary;
    final onSecondary = theme.colorScheme.onSecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCircleButton(
          icon: Icons.skip_previous,
          onPressed: onPrevious,
          backgroundColor: secondaryColor,
          iconColor: onSecondary,
          size: 36,
        ),
        SizedBox(width: 24.w),
        _buildCircleButton(
          icon: isPlaying ? Icons.pause : Icons.play_arrow,
          onPressed: onPlayPause,
          backgroundColor: primaryColor,
          iconColor: onPrimary,
          size: 48,
        ),
        SizedBox(width: 24.w),
        _buildCircleButton(
          icon: Icons.skip_next,
          onPressed: onNext,
          backgroundColor: secondaryColor,
          iconColor: onSecondary,
          size: 36,
        ),
      ],
    );
  }
}
